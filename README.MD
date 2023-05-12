# FOLIO installation scripts, select modules.

Utils, scripts, sample data files etc for installing a local FOLIO backend instance with Okapi, an external PostgreSQL database, auth and user modules and select other modules.

Modules to install are selected and configured in a single JSON file. See ./modules/folio-hebis-reminder-fees.json 

Some scripts here require environment var `FOLIO` to be set to the main checkout directory for FOLIO components, for example

`export FOLIO=~/folio-git-directory; ./script.sh`

## Prerequisites

* PostgreSQL installed and running.
* Kafka installed and running.
* Okapi checked out from folio-org at Github, together with all referenced FOLIO modules.
* Okapi and FOLIO modules built.
* These scripts use `curl` and `jq`

Before installing Okapi, the database with the `okapi` user must be created. See next section.

#### Create Okapi user in PostgreSQL

```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

#### Initialize database

`java -Dport=8600 -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar initdatabase`

#### Start Okapi 

`java -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar dev`

#### Or, to initialize the database and start Okapi
In root of this project, and assuming Okapi is checked out to `<home-dir>/folio` do

`export FOLIO=~/folio; ./okapi/init-db-start-okapi.sh`


## Install modules for tenant diku

To clean up the database schema to start from scratch: 

`./drop-and-recreate-okapi-modules-database.sh`

Run installation 
`export FOLIO=~/folio; ./create-tenants-users-install-modules.sh`  modules/my-folio-config.json

Before installing modules, the config file can be checked with:

`./modules/validate-config.sh modules/my-folio-config.json`

## Miscellaneous

#### Log in to Okapi modules' database
`psql -U folio_admin -d okapi_modules -h localhost`

(was once `psql -U folio_admin postgresql://localhost:5432 okapi_modules`)

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
