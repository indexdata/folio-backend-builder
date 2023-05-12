# Installs listed modules. User diku_admin is created as soon as permissions, users, and login is in place. 
# This is so that permissions can be assigned to diku_admin on a module by module basis.
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

CONF=$1

if [[ -z "$CONF" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./install-a-folio.sh myconf.json"
  exit
else 
  echo "Installing a FOLIO using $CONF"
fi

started=`date`  

# Path to utility scripts for deploying modules 
DEPLOY=$workdir/deploy
# Import jq functions for retrieving setting from the config file 
source $workdir/json-config-reader.sh

tenants=$(tenants $CONF)
curl -w '\n' -D - -H "Content-type: application/json" -d "$tenants" http://localhost:9130/_/proxy/tenants

# Basic infrastructure to create users
userModules=$(jq -r '.userModules[] | .name + ":" + .version' $CONF)
for mod in $userModules; do
  nv=(${mod//:/ })
  MOD="${nv[0]}"
  VERSION="${nv[1]}"
  BASE_DIR=$(baseDir $MOD $VERSION $CONF)
  JAR_PATH=$(pathToJar $MOD $VERSION $CONF)
  DD_SCRIPT=$(deployScript $MOD $VERSION $CONF)
  JAVA_PATH=$(javaHome $MOD $VERSION $CONF)
  PG_HOST=$(pgHost $MOD $VERSION $CONF)
  echo "Register $MOD"
  curl -w '\n' -D - -s  -H \"Content-type: application/json\" -d @$BASE_DIR/$MOD/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
  echo "Deploy $MOD"
  $DEPLOY/$DD_SCRIPT $MOD $VERSION $JAVA_PATH $BASE_DIR $JAR_PATH $PG_HOST
  echo "Install $MOD for diku"
  curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "'$MOD'-'$VERSION'"}' http://localhost:9130/_/proxy/tenants/diku/modules
done

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
#echo Got puId $PU_ID; read

# Install selected modules
selectedModules=$(jq -r '.selectedModules[] | .name + ":" + .version' $CONF)
for mod in $selectedModules; do
  nv=(${mod//:/ })
  MOD="${nv[0]}"
  VERSION="${nv[1]}"

  CFG=$(moduleConfig $MOD $VERSION $CONF)
  if [[ -z "$CFG" ]]; then
    echo "
    ERROR: No configuration found for $MOD-$VERSION
    "
    exit
  fi

  BASE_DIR=$(baseDir $MOD $VERSION $CONF)
  JAR_PATH=$(pathToJar $MOD $VERSION $CONF)
  DEPLOY_TYPE=$(deploymentType $MOD $VERSION $CONF)
  DD_SCRIPT=$(deployScript $MOD $VERSION $CONF)
  DEPLOY_DESCRIPTOR=$(deploymentDescriptor $MOD $VERSION $CONF)
  JAVA_PATH=$(javaHome $MOD $VERSION $CONF)
  PG_HOST=$(pgHost $MOD $VERSION $CONF)
  TENANT_PARAM=$(installParameters $MOD $VERSION $CONF)

  echo "Register $MOD"
  curl -w '\n' -D - -H "Content-type: application/json" -d @$BASE_DIR/$MOD/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
  echo "Deploy $MOD"
  if [[ "$DEPLOY_TYPE" == "DD-STATIC" ]]
    then
      curl -w '\n' -D - -H "Content-type: application/json" -d @$workdir/$DEPLOY_DESCRIPTOR http://localhost:9130/_/discovery/modules
  elif [[ -z "$DD_SCRIPT" ]]; 
    then
      curl -w '\n' -D - -H "Content-type: application/json" -d '{"srvcId": "'$MOD'-'$VERSION'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
  else 
    $DEPLOY/$DD_SCRIPT $MOD $VERSION $JAVA_PATH $BASE_DIR $JAR_PATH $PG_HOST
  fi
  if [[ "$MOD" != "mod-authtoken" && "$MOD" != "mod-users-bl" ]]  # Activation deferred until permissions assigned for all modules.
    then
     echo "Install $MOD for diku"
     if [[ ! -z "$TENANT_PARAM" ]]; then
       # Has tenant init parameters - send to 'install' end-point
       curl -w '\n' -D -     -H "Content-type: application/json" -d '[{"id": "'$MOD'-'$VERSION'", "action": "enable"}]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=$TENANT_PARAM
     else
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

echo "Installatin of a FOLIO using '$CONF' was started at $started"
echo "Ended at `date`"
