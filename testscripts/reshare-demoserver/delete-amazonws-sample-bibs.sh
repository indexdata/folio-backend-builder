token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh  ec2-34-229-181-20.compute-1.amazonaws.com:9130)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://ec2-34-229-181-20.compute-1.amazonaws.com:9130/item-storage/items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://ec2-34-229-181-20.compute-1.amazonaws.com:9130/holdings-storage/holdings
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://ec2-34-229-181-20.compute-1.amazonaws.com:9130/instance-storage/instances
