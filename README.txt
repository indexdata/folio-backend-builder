Utils, scripts, sample data files etc for installing a local FOLIO backend instance with
Okapi, an external PostgreSQL database, auth and user modules and select other modules. 


Prerequisites: 
  - PostgreSQL installed 
     (on October 18 2017, local PostgreSQL was updated to 9.6, required by some db update scripts in RMB)

  - Okapi database user created in PostgreSQL, and okapi database initialized 
     See: https://github.com/folio-org/okapi/blob/master/doc/guide.md#storage

     At time of writing: 
      sudo -u postgres -i
      createuser -P okapi   # When it asks for a password, enter okapi25
      createdb -O okapi okapi

      java -Dport=8600 -Dstorage=postgres -jar target/okapi-core-fat.jar initdatabase
        (inttdatabase will reuse existing tables)

  - Okapi started 
      java -Dstorage=postgres -jar okapi-core/target/okapi-core-fat.jar dev

  - Tenant 'diku' created
      ./create-tenant.sh

Option 1) Remove modules database and install modules from scratch

  ./drop-and-create-okapi_modules.sh 
  
  Then follow "Option 2) Install authn modules from scratch"

Option 2) Install authn modules from scratch
 
  ./create-pg-database-okapi_modules.sh
  ./create-pg-superuser-folio-admin.sh

  cd deployment-descriptors 
  ./deploy-assign-all-except-authtoken.sh

  cd ../diku_admin
  ./CREATE-diku_admin.sh
    (this assumes that the permissions set up in permissions.json are still valid,
     the 'get-xyz' scripts can fetch new data if not. There are then assumptions in
     the scripts about the UUID to use, fetching new user/creds/perms may require changes to that)

  cd ../deployment-descriptors
  ./deploy-assign-authtoken.sh
    (locks down the API access)
  

Option 3) Deploy authn modules and other modules again after Okapi re-start

  ./deploy-all-after-restart.sh

