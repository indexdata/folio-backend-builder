token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/item-storage/items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/holdings-storage/holdings
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/instance-storage/instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/53cf956f-c1df-410b-8bea-27f712cca7c0
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/fcd64ce1-6995-48f0-840e-89ffa2288371
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/758258bc-ecc1-41b8-abca-f7b610822ffd
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/b241764c-1466-4e1d-a028-1a3684a5da87
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/f34d27c6-a8eb-461b-acd6-5dea81771e70
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/libraries/5d78803e-ca04-4b4a-aeae-2c63b924518b
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/campuses/62cf76b7-cca5-4d33-9217-edf42ce1a848
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/institutions/40ee00ca-a518-4b49-be01-0638d0a4ac57
