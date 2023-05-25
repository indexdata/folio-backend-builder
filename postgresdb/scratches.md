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