./okapi/create-tenant.sh

./drop-pgdb-okapi_modules-and-roles.sh

./create-pgdb-okapi_modules.sh

./authn-proxy-modules/register-all-module-proxies.sh

./deployment-descriptors/deploy-assign-all-except-authtoken.sh

./other-modules/proxy-deploy-assign-modules.sh

./other-modules/inventory/proxy-deploy-assign-modules-localhost.sh

./ui-modules/proxy-enable-ui-modules.sh

./diku_admin/create-diku_admin.sh

cd $FOLIO/mod-inventory-storage/sample-data/

./import.sh diku

#$FOLIO/install-folio-backend/other-modules/graphql/proxy-deploy-assign-localhost.sh

cd $FOLIO/install-folio-backend

./deployment-descriptors/deploy-assign-authtoken.sh

