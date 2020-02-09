host=$1

token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh  $host)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/item-storage/items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/holdings-storage/holdings
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/instance-storage/instances

