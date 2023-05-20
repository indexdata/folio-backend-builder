# Installs all selected modules. User diku_admin is created once basic user infrastructure is in place,
#so that permissions can be assigned to diku_admin during subsequent module installations.

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  printf "Please provide JSON config file listing and configuring modules to be install:  ./install-folio.sh projects/my-folio.json\n"
  exit
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  printf "\n\nError: Could not find JSON config file [%s]. Have to bail, sorry.\n\n" "$CONFIG_FILE"
  exit 
fi
started=$(date)

# Import jq functions for retrieving installation instructions from the passed-in configuration file
source "$workdir/configutils/jsonConfigReader.sh"

# Functions for: Error reporting, manipulation of descriptors, registration and deployment.

## Error reporting functions
Errors=()
format="\nSTATUS::%{response_code}\nURL::%{url}"
function statusCode() {
  formattedResponse="$1"
  printf "%s\n " "$formattedResponse" | sed -n -e 's/STATUS:://p'
}
function logError() {
  Errors=("${Errors[@]}" "$1")
}
function report() {
  resp="$1"
  status=$(statusCode "$resp")
  if [[ " 200 201 " == *"$status"* ]]; then
    printf " OK.\n";
  else
    logError "$resp"
    printf "%s\n" "$resp"
  fi
}
## Will assemble a deployment descriptor from the JSON configuration using the config reader
function deploymentDescriptor() {
  moduleName="$1"
  id="$2"
  method=$(deploymentMethod "$moduleName" "$CONFIG_FILE")
  if [[ "$method" == "DD" ]]; then
    jvm=$(javaHome "$moduleName" "$CONFIG_FILE")
    dir=$(baseDir "$moduleName" "$CONFIG_FILE")
    jar=$(pathToJar "$moduleName" "$CONFIG_FILE")
    env=$(env "$moduleName" "$CONFIG_FILE")
    echo '{ "srvcId": "'"$id"'",  "nodeId": "localhost",
            "descriptor": {
              "exec": "'"$jvm"/bin/java' -Dport=%p -jar '"$dir"'/'"$moduleName"'/'"$jar"' -Dhttp.port=%p",
              "env": '"$env"' }}'
  fi
}
## Will retrieve the ID from the module descriptor in the checked-out module's /target directory
function idFromModuleDescriptor() {
  moduleName=$1
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  mdPath="$baseDir/$moduleName/target/ModuleDescriptor.json"
  if [[ -f "$mdPath" ]]; then
    jq -r '.id' "$mdPath"
  else
    logError "Could not find module descriptor in $baseDir/$moduleName (module not compiled?)"
    echo ""
  fi
}
## For docker based deployment, PG_HOST is changed from the common 'postgres' to the IP of this host
## It's not known if the method for obtaining the host IP below is cross-platform.
function setPgHostInModuleDescriptor() {
  moduleName=$1
  thisHost=$(hostname -I | { read first rest ; echo $first ; })
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  newMd=$(jq --arg pgHost "$thisHost" -r '(.launchDescriptor.env[] | select(.name == "DB_HOST")).value=$pgHost ' "$baseDir/$moduleName/target/ModuleDescriptor.json")
  echo "$newMd" > "$baseDir/$moduleName/target/ModuleDescriptor.json" 
}
## Will post partly generated, partly static ModuleDescriptors and DeploymentDescriptors to Okapi.
function registerAndDeploy() {
  moduleName=$1
  if [[ -z $(moduleConfig "$moduleName" "$CONFIG_FILE") ]]; then
    printf "ERROR: No configuration found in %s for %s. Have to bail." "$CONFIG_FILE" "$moduleName"
    exit
  fi
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  method=$(deploymentMethod "$moduleName" "$CONFIG_FILE")
  moduleId=$(idFromModuleDescriptor "$moduleName" "$CONFIG_FILE")
  if [[ -n "$moduleId" ]]; then
    if [[ "$method" == "DOCKER" ]]; then
        setPgHostInModuleDescriptor "$moduleName"
    fi
    printf "Register %s. " "$moduleId"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d @"$baseDir"/"$moduleName"/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules)"
    printf "Deploy %s. " "$moduleId"
    if [[ "$method" == "DD" ]]
      then
        deploymentDescriptor=$(deploymentDescriptor "$moduleName" "$moduleId" "$CONFIG_FILE")
        report "$(curl -s -w "$format" -H "Content-type: application/json" -d "$deploymentDescriptor" http://localhost:9130/_/discovery/modules)"
    else
        report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"srvcId": "'"$moduleId"'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules)"
    fi
  else
    logError "Could not find module id. $moduleName not being installed. "
  fi
}

# Main installation routines

## Basic user infrastructure to be able to create a user with credentials and permissions
### Create tenant
tenants=$(tenants "$CONFIG_FILE")
printf "Create tenant %s " "$tenants"
report "$(curl -s -w "$format" -H "Content-type: application/json" -d "$tenants" http://localhost:9130/_/proxy/tenants)"
### Deploy fake APIs, if any
if [[ "null" != "$(jq -r '.fakeApis.provides' "$CONFIG_FILE")" ]]; then
  pathToFaker="$workdir/configutils/api-faker"
  provides="$(jq -r '.fakeApis.provides' "$CONFIG_FILE")"
  if [ ! -f "$pathToFaker/target/mod-fake-fat.jar" ];  then
    mvn clean install -f "$pathToFaker"
  fi
  moduleDescriptor=$(jq --argjson provides "$provides" '.provides=$provides' "$pathToFaker/descriptors/ModuleDescriptor.json")
  printf "Declare fake APIs."
  report "$(curl -s -w "$format" -H "Content-type: application/json" -d "$moduleDescriptor" http://localhost:9130/_/proxy/modules)"
  deploymentDescriptor=$(jq --arg jarPath "$pathToFaker/target" -r '(.descriptor.exec)="java -Dport=%p -DlogLevel=INFO -jar "+$jarPath+"/mod-fake-fat.jar"' "$pathToFaker/descriptors/DeploymentDescriptor.json")
  printf "Deploy stub."
  report "$(curl -s -w "$format" -H "Content-type: application/json" -d "$deploymentDescriptor" http://localhost:9130/_/discovery/modules)"
  printf "Enable faker for diku."
  report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "mod-fake-1.0.0"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
fi
### Install basic modules
basicModules=$(jq -r '.basicModules[] | .name' "$CONFIG_FILE")
for name in $basicModules; do
  registerAndDeploy "$name" "$CONFIG_FILE"
  if [[ "$name" != "mod-authtoken" && "$name" != "mod-users-bl" ]]; then  # Activation deferred until permissions assigned for all modules.
    moduleId=$(idFromModuleDescriptor "$name" "$CONFIG_FILE")
    printf "Install %s for diku. " "$moduleId"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$moduleId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
  fi
done
### Create a user with credentials and initial permissions
users=$(users "$CONFIG_FILE")
printf "Create user diku_admin. "
report "$(curl -s -w "$format" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$users" http://localhost:9130/users)"
credentials=$(credentials "$CONFIG_FILE")
printf "Give diku_admin credentials. "
report "$(curl -s -w "$format" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$credentials" http://localhost:9130/authn/credentials)"
printf "Give diku_admin initial permissions. "
PU_ID=$(curl -s -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d '{
    "userId" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
    "permissions" : ["perms.all", "login.all", "users.all", "configuration.all"]}' http://localhost:9130/perms/users | jq -r '.id')
if [[ "$PU_ID" == "null" ]]; then
  printf "Error: There was a problem giving diku_admin initial permissions."
  logError "There was a problem giving diku_admin initial permissions."
else
  printf " OK.\n"
fi

## Install selected/optional modules

selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name' "$CONFIG_FILE")
for name in $selectedModules; do
  registerAndDeploy "$name"
  moduleId=$(idFromModuleDescriptor "$name" )
  tenantParams=$(installParameters "$name" "$CONFIG_FILE")
  if [[ -n "$tenantParams" ]]; then
    # Has tenant init parameters - send to 'install' end-point
    printf "Install %s for diku with parameters %s. " "$name" "$tenantParams"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d '[{"id": "'"$moduleId"'", "action": "enable"}]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters="$tenantParams")"
  else
    printf "Assign %s to diku. " "$name"
    respAssign="$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$moduleId"'", "action": "enable"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
    report "$respAssign"
  fi
  status=$(statusCode "$respAssign")
  if [[ " 200 201 " == *"$status"* ]]; then
    userPermissions=$(permissions "$name" "$CONFIG_FILE")
    for permission in $userPermissions; do
      printf " - Permit %s. " "$permission"
      report "$(curl -s -w "$format" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
        -d '{"permissionName": "'"$permission"'"}' http://localhost:9130/perms/users/"$PU_ID"/permissions)"
    done
  else
    printf "Installation of %s failed, cannot assign permissions.\n" "$name"
  fi
done

## Enable authentication

printf "\nLock down module access to authenticated users\n"
authId=$(idFromModuleDescriptor "mod-authtoken" )
printf "Assign mod-authtoken to DIKU. "
report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$authId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
usersId=$(idFromModuleDescriptor "mod-users-bl" )
printf "Assign mod-users-bl to DIKU. "
report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$usersId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"

# Reporting

## Report results

printf "\n\nInstallation of a FOLIO using %s finished\n\n" "$CONFIG_FILE"
printf "Started: %s\n" "$started"
printf "Ended:   %s\n" "$(date)"
printf "\nInstalled modules, diku:\n"
curl -s http://localhost:9130/_/proxy/tenants/diku/modules | jq -r '.[].id'
## Report any errors
if [ "${#Errors[@]}" == "0" ]; then
  printf "\n\nThe installation of [%s] completed!\n\n" "$CONFIG_FILE"
else
  printf "\n\n************************************************\nThe installation had errors:\n\n"
  for i in "${Errors[@]}"; do
    printf "  * %s\n" "$i"
  done
  printf "\nThe installation had errors\n************************************************\n\n"
fi
