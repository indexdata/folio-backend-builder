token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh  shared-index.reshare-dev.indexdata.com:9130)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://shared-index.reshare-dev.indexdata.com:9130/item-storage/items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://shared-index.reshare-dev.indexdata.com:9130/holdings-storage/holdings
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://shared-index.reshare-dev.indexdata.com:9130/instance-storage/instances
