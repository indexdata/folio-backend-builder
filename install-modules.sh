# Installs all selected modules. User diku_admin is created once basic user infrastructure is in place,
#so that permissions can be assigned to diku_admin during subsequent module installations.
here=${0%/*}
projectFile=$1
if [[ -z "$projectFile" ]]; then
  printf "Please provide JSON config file listing and configuring modules to be install:  ./install-modules.sh projects/my-folio.json\n"
  exit
fi
if [[ ! -f "$projectFile" ]]; then
  printf "\n\nError: Could not find JSON config file [%s]. Got to bail.\n\n" "$projectFile"
  exit 
fi
started=$(date)

# Import jq functions for retrieving installation instructions from the passed-in configuration file
source "$here/lib/ConfigReader.sh"
source "$here/lib/Utils.sh"

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
    printf "\n";
  else
    logError "$resp"
    printf "%s\n" "$resp"
  fi
}
## For docker based deployment, PG_HOST is changed from the common 'postgres' to the IP of this host
## It's not known if the method for obtaining the host IP below is cross-platform.
function setPgHostInModuleDescriptor() {
  moduleName=$1
  thisHost=$(hostname -I | { read first rest ; echo $first ; })
  sourceDirectory=$(moduleDirectory "$moduleName" "$projectFile")
  newMd=$(jq --arg pgHost "$thisHost" -r '(.launchDescriptor.env[] | select(.name == "DB_HOST")).value=$pgHost ' "$sourceDirectory/$moduleName/target/ModuleDescriptor.json")
  echo "$newMd" > "$sourceDirectory/$moduleName/target/ModuleDescriptor.json"
}
## Will post partly generated, partly static ModuleDescriptors and DeploymentDescriptors to Okapi.
function registerAndDeploy() {
  moduleName=$1
  if [[ -z $(moduleConfig "$moduleName" "$projectFile") ]]; then
    printf "ERROR: No configuration found in %s for %s. Have to bail.\n\n" "$projectFile" "$moduleName"
    exit
  fi
  sourceDirectory=$(moduleDirectory "$moduleName" "$projectFile")
  method=$(deploymentMethod "$moduleName" "$projectFile")
  moduleId=$(moduleDescriptorId "$moduleName" "$projectFile")
  if [[ -n "$moduleId" ]]; then
    if [[ "$method" == "DOCKER" ]]; then
        setPgHostInModuleDescriptor "$moduleName"
    fi
    printf "Register %-40s" "$moduleId"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d @"$sourceDirectory"/"$moduleName"/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules)"
    jarFile=$(pathToJar "$moduleName" "$projectFile")
    if [[ $jarFile == "null" ]]; then
      filesAge="?"
    else
      fullPathToJar="$sourceDirectory"/"$moduleName"/"$jarFile"
      if [[ -f "$fullPathToJar" ]]; then
        filesAge="$(filesAge "$fullPathToJar")"
      else
        altName="${fullPathToJar%/*}/$moduleId.jar"
        if [[ -f "$altName" ]]; then
          printf "Project file says %s but got %s\n" "${fullPathToJar##*/}" "${altName##*/}"
          filesAge="$(filesAge "$altName")"
        else
          logError "Could not find jar file. $moduleName not being installed. "
        fi
      fi
    fi
    printf "Deploy   - %-40s%s from %s %s  Age: %s" "$moduleId" "$(gitStatus "$sourceDirectory/$moduleName")" "$sourceDirectory" "$(moduleRepo "$moduleName" "$projectFile")" "$filesAge"
    if [[ "$method" == "DD" ]]
      then
        deploymentDescriptor=$(makeDeploymentDescriptor "$moduleName" "$projectFile")
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
tenants=$(tenants "$projectFile")
printf "Create tenant %s" "$tenants"
report "$(curl -s -w "$format" -H "Content-type: application/json" -d "$tenants" http://localhost:9130/_/proxy/tenants)"
### Deploy fake APIs, if any
if [[ "null" != "$(jq -r '.fakeApis.provides' "$projectFile")" ]]; then
  pathToFaker="$here/lib/api-faker"
  provides="$(jq -r '.fakeApis.provides' "$projectFile")"
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
basicModules=$(jq -r '.basicModules[] | .name' "$projectFile")
for name in $basicModules; do
  registerAndDeploy "$name" "$projectFile"
  if [[ "$name" != "mod-authtoken" && "$name" != "mod-users-bl" ]]; then  # Activation deferred until permissions are bootstrapped.
    moduleId=$(moduleDescriptorId "$name" "$projectFile")
    printf "Install  - %-40s" "$moduleId"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$moduleId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
  fi
done
### Create a user with credentials and initial permissions
users=$(users "$projectFile")
printf "***********************\n"
printf "Create user diku_admin. "
report "$(curl -s -w "$format" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$users" http://localhost:9130/users)"
credentials=$(credentials "$projectFile")
printf "Give diku_admin credentials. "
report "$(curl -s -w "$format" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$credentials" http://localhost:9130/authn/credentials)"
printf "Give diku_admin initial permissions.\n"
PU_ID=$(curl -s -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d '{
    "userId" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
    "permissions" : ["perms.all", "login.all", "users.all", "configuration.all", "perms.users.item.post"]}' http://localhost:9130/perms/users | jq -r '.id')
if [[ "$PU_ID" == "null" ]]; then
  printf "Error: There was a problem giving diku_admin initial permissions."
  logError "There was a problem giving diku_admin initial permissions."
else
  printf "***********************\n"
  authId=$(moduleDescriptorId "mod-authtoken" "$projectFile")
  printf "Assign mod-authtoken to DIKU. "
  report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$authId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
  usersId=$(moduleDescriptorId "mod-users-bl" "$projectFile" )
  printf "Assign mod-users-bl to DIKU. "
  report "$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$usersId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
  printf "***********************\n"
fi


TOKEN=$(curl -s -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku"  -d "{ \"username\": \"diku_admin\", \"password\": \"admin\"}" "http://localhost:9130/authn/login" | grep x-okapi-token | tr -d '\r' | cut -d " " -f2)

## Install selected (=optional) modules
selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name' "$projectFile")
for name in $selectedModules; do
  registerAndDeploy "$name"
  moduleId=$(moduleDescriptorId "$name" "$projectFile" )
  tenantParams=$(installParameters "$name" "$projectFile")
  if [[ -n "$tenantParams" ]]; then
    # Has tenant init parameters - send to 'install' end-point
    printf "Install  - %s with parameters %s. " "$name" "$tenantParams"
    report "$(curl -s -w "$format" -H "Content-type: application/json" -d '[{"id": "'"$moduleId"'", "action": "enable"}]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters="$tenantParams")"
  else
    printf "Assign   - %-40s" "$name"
    respAssign="$(curl -s -w "$format" -H "Content-type: application/json" -d '{"id": "'"$moduleId"'", "action": "enable"}' http://localhost:9130/_/proxy/tenants/diku/modules)"
    report "$respAssign"
  fi
  status=$(statusCode "$respAssign")
  if [[ " 200 201 " == *"$status"* ]]; then
    userPermissions=$(permissions "$name" "$projectFile")
    for permission in $userPermissions; do
      printf " - Permit %s. " "$permission"
      report "$(curl -s -w "$format" -H "X-Okapi-Token: $TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
        -d '{"permissionName": "'"$permission"'"}' http://localhost:9130/perms/users/"$PU_ID"/permissions)"
    done
  else
    printf "Installation of %s failed, cannot assign permissions.\n" "$name"
  fi
done

# Reporting

## Report results

printf "\n\nInstallation of a FOLIO using %s finished\n\n" "$projectFile"
printf "\nInstalled modules, diku:\n"
curl -s http://localhost:9130/_/proxy/tenants/diku/modules | jq -r '.[].id'
## Report any errors
if [ "${#Errors[@]}" == "0" ]; then
  printf "\n\nThe installation of [%s] completed!\n\n" "$projectFile"
  printf "Started: %s\n" "$started"
  printf "Ended:   %s\n" "$(date)"
else
  printf "\n\n************************************************\nThe installation had errors:\n\n"
  for i in "${Errors[@]}"; do
    printf "  * %s\n" "$i"
  done
  printf "\nThe installation had errors\n************************************************\n\n"
fi
