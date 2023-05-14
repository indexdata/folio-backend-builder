# Installs listed modules. User diku_admin is created as soon as permissions, users, and login is in place. 
# This is so that permissions can be assigned to diku_admin on a module by module basis.
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

CONF=$1

if [[ -z "$CONF" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./install-folio.sh projects/my-folio.json"
  exit
else 
  echo "Installing a FOLIO using $CONF"
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source $workdir/configutils/json-config-reader.sh
# Assembles DeploymentDescriptors from the JSON configuration using the config reader
deploymentDescriptor() {
  module="$1"
  version="$2"
  configFile="$3"
  method=$(deploymentMethod "$module" "$version" "$configFile")
  if [[ "$method" == "DD" ]]; then
    jvm=$(javaHome "$module" "$version" "$configFile")
    dir=$(baseDir "$module" "$version" "$configFile")
    jar=$(pathToJar "$module" "$version" "$configFile")
    env=$(env "$module" "$version" "$configFile")
    echo '{
      "srvcId": "'"$module"'-'"$version"'",
      "nodeId": "localhost",
      "descriptor": {
        "exec": "'"$jvm"' -Dport=%p -jar '"$dir"'/'"$module"'/'"$jar"' -Dhttp.port=%p",
        "env": '"$env"'
      }
    }'
  fi
}

registerAndDeploy() {
  mod_version=$1
  configfile=$2
  nv=(${mod_version//:/ })
  MOD=${nv[0]}
  VERSION=${nv[1]}
  BASE_DIR=$(baseDir $MOD $VERSION $configfile)
  METHOD=$(deploymentMethod $MOD $VERSION $configfile)

  CFG=$(moduleConfig $MOD $VERSION $configfile)
  if [[ -z "$CFG" ]]; then
    echo "ERROR: No configuration found for $MOD-$VERSION"
    exit
  fi

  BASE_DIR=$(baseDir $MOD $VERSION $configfile)
  METHOD=$(deploymentMethod $MOD $VERSION $configfile)

  echo "Register $MOD"
  curl -w '\n' -D - -H "Content-type: application/json" -d @$BASE_DIR/$MOD/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
  echo "Deploy $MOD"
  if [[ "$METHOD" == "DD" ]]
    then
      deploymentDescriptor=$(deploymentDescriptor $MOD $VERSION $configfile)
      curl -w '\n' -D - -s -H "Content-type: application/json" -d "$deploymentDescriptor" http://localhost:9130/_/discovery/modules
  else
      curl -w '\n' -D - -H "Content-type: application/json" -d '{"srvcId": "'$MOD'-'$VERSION'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
  fi
}

tenants=$(tenants $CONF)
curl -w '\n' -D - -H "Content-type: application/json" -d "$tenants" http://localhost:9130/_/proxy/tenants

# Basic infrastructure to be able to create users with credentials
userModules=$(jq -r '.userModules[] | .name + ":" + .version' $CONF)
for mod in $userModules; do
  registerAndDeploy $mod $CONF
  echo "Install $MOD for diku"
  curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "'$MOD'-'$VERSION'"}' http://localhost:9130/_/proxy/tenants/diku/modules
done

# Creating a user with credentials and initial permissions
users=$(users $CONF)
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$users" http://localhost:9130/users
credentials=$(credentials $CONF)
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d "$credentials" http://localhost:9130/authn/credentials
echo "
Give diku_admin permissions for perms, login, users
"
PU_ID=$(curl -s -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d '{
    "userId" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
    "permissions" : [
      "perms.all",
      "login.all",
      "users.all"
    ]
}' http://localhost:9130/perms/users | jq -r '.id')

# Install selected modules
selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name + ":" + .version' $CONF)
for mod in $selectedModules; do
  registerAndDeploy $mod $CONF

  if [[ "$MOD" != "mod-authtoken" && "$MOD" != "mod-users-bl" ]]  # Activation deferred until permissions assigned for all modules.
    then
     TENANT_PARAM=$(installParameters $MOD $VERSION $CONF)
     if [[ -n "$TENANT_PARAM" ]]; then
       # Has tenant init parameters - send to 'install' end-point
       echo "Install $MOD for diku"
       curl -w '\n' -D -     -H "Content-type: application/json" -d '[{"id": "'$MOD'-'$VERSION'", "action": "enable"}]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=$TENANT_PARAM
     else
       echo "Assign $MOD to diku"
       curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "'$MOD'-'$VERSION'", "action": "enable"}' http://localhost:9130/_/proxy/tenants/diku/modules
     fi
     PERMISSIONS=$(permissions $MOD $VERSION $CONF)
     for permission in $PERMISSIONS; do
          curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
          -d '{"permissionName": "'$permission'"}' http://localhost:9130/perms/users/$PU_ID/permissions
     done
  fi  
done

echo "Locks down module access to authenticated users"
authVersion=$(moduleVersionByName  "mod-authtoken" $CONF)
echo "Assign mod-authtoken to DIKU"
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-'$authVersion'"}' http://localhost:9130/_/proxy/tenants/diku/modules
usersVersion=$(moduleVersionByName  "mod-users-bl" $CONF)
echo Assign mod-users-bl to DIKU
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-'$usersVersion'"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo "Installation of a FOLIO using '$CONF' was started at $started"
echo "Ended at $(date)"
echo "Installed modules, diku:" 
echo " "
curl -s http://localhost:9130/_/proxy/tenants/diku/modules | jq -r '.[].id'