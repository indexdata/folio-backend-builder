workdir=$FOLIO/install-folio-backend

./okapi/create-tenant.sh

./drop-pgdb-okapi_modules-and-roles.sh

./create-pgdb-okapi_modules.sh

./register-deploy-assign-modules.sh

./ui-modules/proxy-enable-ui-modules.sh

# cd $FOLIO/mod-inventory-storage/sample-data/

# ./import.sh diku > sample-data.log


$workdir/diku_admin/create-diku_admin.sh

# Locks down module access to authenticated users
echo Deploy mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-authtoken.json http://localhost:9130/_/discovery/modules
echo Assign mod-authtoken to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-2.5.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users-bl/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-bl.json http://localhost:9130/_/discovery/modules
echo Assign mod-users-bl to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-5.2.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
