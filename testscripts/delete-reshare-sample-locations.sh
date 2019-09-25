token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
echo 305d
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/81582666-305d-4c8e-82cc-061fd00e9c42
echo a7b3
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/d05b8941-a7b3-4519-b450-06d72ca13a0c
echo c97c
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/libraries/b9f519c5-c97c-4c7b-9e42-bc239473370f
echo 1c38
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/libraries/43364fab-1c38-42ff-aa28-68660f459ef0
echo 0541
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/campuses/57953bb9-0541-4190-a9de-abf200317f5c
echo 6da4
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/campuses/0f1c2f1f-6da4-4e7e-948c-c396ac57e237
echo 8c12
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/institutions/6dab32a8-8c12-441c-ac5e-b2f12be8eb8d
echo ed9c
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/institutions/542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67
