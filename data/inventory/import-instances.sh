#!/usr/bin/env bash

tenant=${1:-diku}
token=$(curl -s -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku"  -d "{ \"username\": \"diku_admin\", \"password\": \"admin\"}" http://localhost:9130/authn/login | grep x-okapi-token | cut -d " " -f2 );
datadir=$FOLIO/mod-inventory-storage/sample-data
instance_storage_address=http://localhost:9130/instance-storage/instances

for f in $datadir/instances/*.json; do
    curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: ${tenant}" \
         -H "X-Okapi-Token: ${token}" \
         -d @$f \
         "${instance_storage_address}"
done
