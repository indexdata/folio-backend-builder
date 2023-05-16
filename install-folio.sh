# Installs listed modules. User diku_admin is created as soon as permissions, users, and login is in place. 
# This is so that permissions can be assigned to diku_admin on a module by module basis.
#
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./install-folio.sh projects/my-folio.json"
  exit
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source "$workdir/configutils/jsonConfigReader.sh"

# Assembles DeploymentDescriptors from the JSON configuration using the config reader
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
              "exec": "'"$jvm"' -Dport=%p -jar '"$dir"'/'"$moduleName"'/'"$jar"' -Dhttp.port=%p",
              "env": '"$env"' }}'
  fi
}
# Retrieves the ID from the module descriptor in the checked out module's /target/ directory
function idFromModuleDescriptor() {
  moduleName=$1
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  jq -r '.id' "$baseDir/$moduleName/target/ModuleDescriptor.json"
}

function registerAndDeploy() {
  moduleName=$1
  if [[ -z $(moduleConfig "$moduleName" "$CONFIG_FILE") ]]; then
    echo "ERROR: No configuration found in $CONFIG_FILE for $moduleName"
    exit
  fi
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  method=$(deploymentMethod "$moduleName" "$CONFIG_FILE")
  moduleId=$(idFromModuleDescriptor "$moduleName" "$CONFIG_FILE")

  echo "Register $moduleId"
  curl -w '\n' -D - -H "Content-type: application/json" -d @"$baseDir"/"$moduleName"/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
  echo "Deploy $moduleId"
  if [[ "$method" == "DD" ]]
    then
      deploymentDescriptor=$(deploymentDescriptor "$moduleName" "$moduleId" "$CONFIG_FILE")
      curl -w '\n' -D - -H "Content-type: application/json" -d "$deploymentDescriptor" http://localhost:9130/_/discovery/modules
  else
      curl -w '\n' -D - -H "Content-type: application/json" -d '{"srvcId": "'"$moduleId"'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
  fi
}

# Basic infrastructure to be able to create a user with credentials and permissions
tenants=$(tenants "$CONFIG_FILE")
curl -w '\n' -D - -H "Content-type: application/json" -d "$tenants" http://localhost:9130/_/proxy/tenants
basicModules=$(jq -r '.basicModules[] | .name' "$CONFIG_FILE")
for name in $basicModules; do
  registerAndDeploy "$name" "$CONFIG_FILE"
  if [[ "$name" != "mod-authtoken" && "$name" != "mod-users-bl" ]]; then  # Activation deferred until permissions assigned for all modules.
    moduleId=$(idFromModuleDescriptor "$name" "$CONFIG_FILE")
    echo "Install $moduleId for diku"
    curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "'"$moduleId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules
  fi
done

# Creating a user with credentials and initial permissions
users=$(users "$CONFIG_FILE")
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$users" http://localhost:9130/users
credentials=$(credentials "$CONFIG_FILE")
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$credentials" http://localhost:9130/authn/credentials
PU_ID=$(curl -s -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d '{
    "userId" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
    "permissions" : ["perms.all", "login.all", "users.all", "configuration.all"]}' http://localhost:9130/perms/users | jq -r '.id')

# Install selected modules
selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name' "$CONFIG_FILE")
for name in $selectedModules; do
  registerAndDeploy "$name"
  moduleId=$(idFromModuleDescriptor "$name" )
  tenantParams=$(installParameters "$name" "$CONFIG_FILE")
  if [[ -n "$tenantParams" ]]; then
    # Has tenant init parameters - send to 'install' end-point
    echo "Install $name for diku with parameters $tenantParams"
    curl -w '\n' -D - -H "Content-type: application/json" -d '[{"id": "'"$moduleId"'", "action": "enable"}]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters="$tenantParams"
  else
    echo "Assign $name to diku"
    curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "'"$moduleId"'", "action": "enable"}' http://localhost:9130/_/proxy/tenants/diku/modules
  fi
  userPermissions=$(permissions "$name" "$CONFIG_FILE")
  for permission in $userPermissions; do
      curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
      -d '{"permissionName": "'"$permission"'"}' http://localhost:9130/perms/users/"$PU_ID"/permissions
  done
done

echo "Locks down module access to authenticated users"
authId=$(idFromModuleDescriptor "mod-authtoken" )
echo "Assign mod-authtoken to DIKU"
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "'"$authId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules
usersId=$(idFromModuleDescriptor "mod-users-bl" )
echo Assign mod-users-bl to DIKU
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "'"$usersId"'"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo "Installation of a FOLIO using '$CONFIG_FILE' was started at $started"
echo "Ended at $(date)"
echo "Installed modules, diku:" 
echo " "
curl -s http://localhost:9130/_/proxy/tenants/diku/modules | jq -r '.[].id'