## Miscellaneous notes

#### Log in to Okapi modules' database

`psql -U folio_admin -d okapi_modules -h localhost   # pw folio_admin`se

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

## Manual installation of PG users, databases (not replaced with docker container):



## One time preparation of the database

### Create okapi user, okapi database, folio_admin user in Postgres (once)

Create okapi user

```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

Create folio_admin user that modules will use for access to their database schema in the `okapi_modules` database.

```
sudo -u postgres -i
createuser -P --superuser folio_admin   # When it asks for a password, enter folio_admin
```

## Recurring preparations of the database and Okapi

Following actions can be performed before each new run of the modules installation script to clean up previous
installations.

#### Create the modules database, potentially removing previously installed modules first

Clean up first:
`./postgresdb/drop-pgdb-okapi_modules-and-roles.sh`

Create the database (again):
`./postgresdb/create-pg-okapi_modules.sh`
