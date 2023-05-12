# FOLIO installation scripts.

Scripts for installing a local FOLIO backend all built from source, based on a project specific installation file written in JSON.

Given the prerequisites described below, the scripts will configure a local PostgreSQL database, and initialize and start Okapi. Next, a JSON configuration file that lists the modules to install will be used for declaring, deploying and enabling the modules with Okapi. The configuration also contains settings for tenants and users, though they are currently required to be 'diku' and 'diku_admin' respectively. See ./modules/folio-hebis-reminder-fees.json 

The order of operations off the main installation script is roughly:

* Create tenant diku 
* Install basic modules for the user infrasctructure
* Create user 'diku_admin' with credentials
* Install selected FOLIO modules for 'diku' with permissions to 'diku_admin' 
* Lock down auth by enabling authtoken and users-bl for tenant diku

Some scripts here require that the environment var `FOLIO` is set to the main checkout directory for FOLIO components, for example

`export FOLIO=~/folio; ./script.sh`

## Prerequisites

* PostgreSQL installed and running.
* Kafka installed and running.
* Okapi checked out from folio-org at Github, together with all FOLIO modules to be installed.
* Okapi and FOLIO modules are built (`mvn install`), some perhaps dockerized.
* PostgreSQL has a user 'okapi' and a database 'okapi' created (see instructions next).
* `curl` and `jq` will be needed for running the module installations scripts.

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

#### Or, use this script instead to both initialize the database and start Okapi

In root of this project, and assuming Okapi is checked out to `$HOME/folio` do

`export FOLIO=~/folio; ./okapi/init-db-start-okapi.sh`

## Install modules for tenant diku

To clean up the database schema first and start from scratch, do: 

`./postgresdb/drop-and-recreate-okapi-modules-database.sh`

Then run the installation itself; pass in the project configuration JSON: 

`export FOLIO=~/folio; ./create-tenants-users-install-modules.sh modules/my-folio-config.json`

Optionally, the install configuration can be (lightly) checked using:

`./modules/validate-config.sh modules/my-folio-config.json`

## Miscellaneous notes

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
