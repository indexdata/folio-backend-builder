host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://$host/holdings-storage/holdings?query=instanceId%3D%3D3876fbc5-4639-4cbd-bdde-b02c6d297277


curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://$host/item-storage/items?query=holdingsRecordId%3D%3Dbda5317f-31b6-4308-8646-98507c0092bd