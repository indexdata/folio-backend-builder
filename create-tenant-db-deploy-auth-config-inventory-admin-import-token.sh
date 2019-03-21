workdir=$FOLIO/install-folio-backend

./okapi/create-tenant.sh

./drop-pgdb-okapi_modules-and-roles.sh

./create-pgdb-okapi_modules.sh

./register-deploy-assign-modules.sh

./ui-modules/proxy-enable-ui-modules.sh

cd $FOLIO/mod-inventory-storage/sample-data/

./import.sh diku

$workdir/diku_admin/create-diku_admin.sh


# Locks down module access to authenticated users
echo Deploy mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-authtoken.json http://localhost:9130/_/discovery/modules
echo Assign mod-authtoken to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-1.4.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

