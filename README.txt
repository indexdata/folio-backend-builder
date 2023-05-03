Utils, scripts, sample data files etc for installing a local FOLIO backend instance with
Okapi, an external PostgreSQL database, auth and user modules and select other modules.


Prerequisites:
  - PostgreSQL installed

  - Okapi database user created in PostgreSQL, and okapi database initialized
     See: https://github.com/folio-org/okapi/blob/master/doc/guide.md#storage

     At time of writing:
      sudo -u postgres -i
      createuser -P okapi   # When it asks for a password, enter okapi25
      createdb -O okapi okapi

    Initialize database (empty modules and tenants tables):

      java -Dport=8600 -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar initdatabase
        (initdatabase will reuse existing tables)

  - Okapi started
      java -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar dev

    (or both of the above:  ./okapi/init-db-start-okapi.sh)

  - Create tenant 'diku'
  ./okapi/create-tenants.sh

Option 1) Remove modules database

  ./postgresdb/drop-pgdb-okapi_modules-and-roles.sh

  Then follow "Option 2) Install authn modules from scratch"

Option 2) Create modules database and install authn modules, then other modules, from scratch

  ./postgresdb/create-pgdb-okapi_modules.sh

  If super user folio_admin does not already exist (the general installation script does NOT drop folio_admin)
  ./create-pg-superuser-folio-admin.sh

  Register base modules proxies:
  ./authn-proxy-modules/register-all-module-proxies.sh

  ./deployment-descriptors/deploy-assign-all-except-authtoken.sh

  ./modules/proxy-deploy-assign-modules.sh

  ./modules/inventory/proxy-deploy-assign-modules-localhost.sh

  ./diku_admin/create-diku_admin.sh
    (this assumes that the permissions set up in permissions.json are still valid,
     the diku_admin/get-'xyz'.sh scripts can fetch new data if not. There are then assumptions in
     the scripts about the UUID to use, fetching new user/creds/perms may require changes to that)

  Can import inventory sample data from mod-inventory-storage before lock down of
  API access (before next command after this) by this:

  cd $FOLIO/mod-inventory-storage/sample-data/
  ./import.sh diku

  Lock down API access
  ./deployment-descriptors/deploy-assign-authtoken.sh


Option 3) Deploy authn modules and other modules again after Okapi re-start

  ./deploy-all-after-restart.sh



Test:

token=$(./util-scripts/get-token-diku_admin.sh localhost:9130)

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/users

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/identifier-types

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/instance-storage/instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/instance-formats

Log in to dabase: psql -U folio_admin postgresql://localhost:5432/okapi_modules     folio_admin
  Schemas:  \dn
  Describe table:  \d diku_mod_inventory_storage.instance

