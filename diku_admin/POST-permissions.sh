workdir=$FOLIO/install-folio-backend/diku_admin

curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -X POST -d@$workdir/permissions.json http://localhost:9130/perms/users