host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/locations/c8f57ff4-366f-4c94-8186-d6439fae1d22
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/location-units/libraries/2117d011-f52b-4efe-ab97-f11d0a4b77e5
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/location-units/campuses/3a028d8d-2fd9-4219-90d4-58a2f50a28be
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/location-units/institutions/3a028d8d-2fd9-4219-90d4-58a2f50a28be
