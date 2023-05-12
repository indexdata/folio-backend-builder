# Installs listed modules. User diku_admin is created as soon as permissions, users, and login is in place. 
# This is so that permissions can be assigned to diku_admin on a module by module basis.
# OBS:
# Requires environment variable `FOLIO` to be set to the directory where FOLIO modules are checked out to. 
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

CONF=$1

if [[ -z "$CONF" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./create-diku-admin-install-modules.sh myconf.json"
  exit
fi


# Path to utility scripts for deploying modules 
DEPLOY=$workdir/deploy
# Import jq functions for retrieving setting from the config file 
source $workdir/json-config-reader.sh

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

echo "
Creating user diku_admin in order to assign permissions to them.
"
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d  '{
  "username" : "diku_admin",
  "id" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
  "active" : true,
  "proxyFor" : [ ],
  "personal" : {
    "lastName" : "ADMINISTRATOR",
    "firstName" : "DIKU",
    "email" : "admin@diku.example.org",
    "addresses" : [ ]
  }
}' http://localhost:9130/users

echo "
Assigning password 'admin' to diku_admin
"
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -X POST -d '{ "userId":"1ad737b0-d847-11e6-bf26-cec0c932ce01",
  "password":"admin" }' http://localhost:9130/authn/credentials

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
  elif [[ -z "$DD_SCRIPT" || "$DD_SCRIPT" == "null" ]]; 
    then
      curl -w '\n' -D - -H "Content-type: application/json" -d '{"srvcId": "'$MOD'-'$VERSION'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
  else 
    $DEPLOY/$DD_SCRIPT $MOD $VERSION $JAVA_PATH $BASE_DIR $JAR_PATH $PG_HOST
  fi
  if [[ "$MOD" != "mod-authtoken" && "$MOD" != "mod-users-bl" ]]
    then
     echo "Install $MOD for diku"
     if [[ ! -z "$TENANT_PARAM" && ! "$TENANT_PARAME" == "null" ]]; then
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
