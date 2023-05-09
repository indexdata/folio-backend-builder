SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
GITOLE=~/git-ole
GITID=~/gitprojects


# Set up faux APIs to stand in for required module dependencies that the shared index don't use
echo mod-shared-index-muted-apis
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-shared-index-muted-apis
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-shared-index-muted-apis.json http://localhost:9130/_/discovery/modules

echo Assign mod-shared-index-muted-apis to diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules


# mod-permissions must come before any modules requiring permissions; those modules need to write permissions to it
echo mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/users-and-auth/DeploymentDescriptor-mod-permissions.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-permissions-6.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo enter; read 

#echo mod-tags
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-tags/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-tags
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-tags/target/DeploymentDescriptor.json http://localhost:9130/_/discovery/modules

#echo Assign mod-tags to diku
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-tags-2.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules


echo Register mod-inventory-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/inventory/DeploymentDescriptor-mod-inventory-storage.json http://localhost:9130/_/discovery/modules
echo Install mod-inventory-storage to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue%2CloadSample%3Dtrue

#echo enter; read 

echo mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/users-and-auth/DeploymentDescriptor-mod-users.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-users-19.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo enter; read 

echo mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/users-and-auth/DeploymentDescriptor-mod-login.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-login-7.10.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo enter; read 

echo mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-password-validator-3.1.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-password-validator-3.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo Enter; read

echo register mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

#echo enter; read 

$workdir/ref-mod-circulation.sh

#echo Enter; read


echo mod-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory to diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules




date