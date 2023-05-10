# FOLIO installation scripts, select modules.

Utils, scripts, sample data files etc for installing a local FOLIO backend instance with Okapi, an external PostgreSQL database, auth and user modules and select other modules.


## Prerequisites
* PostgreSQL installed
* Okapi database user created in PostgreSQL, and okapi database initialized and Okapi started. See https://github.com/folio-org/okapi/blob/master/doc/guide.md#storage.

#### Create Okapi user in PostgreSQL
```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

#### Initialize database

```
java -Dport=8600 -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar initdatabase  
```
#### Start Okapi 
```
java -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar dev
```
#### Or for both initializing and starting
```    
./okapi/init-db-start-okapi.sh)
```

## Install modules for tenant diku
```
  ./drop-and-recreate-okapi-modules-database.sh

  ./create-tenants-users-install-modules.sh
```
## Miscellaneous

#### Log in to Okapi modules' database
```
psql -U folio_admin postgresql://localhost:5432/okapi_modules
```
#### Size of databases on disk:

```
SELECT pg_database.datname,  
       pg_size_pretty(pg_database_size(pg_database.datname)) AS size  
  FROM pg_database;

Biggest tables:

SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;
  
```
