workdir=$FOLIO/install-folio-backend/diku_admin
echo PUT permissions for user diku_admin
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -X PUT -d@$workdir/permissions.json http://localhost:9130/perms/users/8d55ce02-472d-4649-a441-1ac16534564a