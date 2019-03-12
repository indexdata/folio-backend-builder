token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d",
        "name": "University of Uptown",
        "code": "UOU"
     }' \
  http://localhost:9130/location-units/institutions

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "57953bb9-0541-4190-a9de-abf200317f5c",
        "name": "Uptown City Campus",
        "code": "UCC",
        "institutionId": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d"
     }' \
  http://localhost:9130/location-units/campuses

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "b9f519c5-c97c-4c7b-9e42-bc239473370f",
        "name": "Uptown University Library",
        "code": "UUL",
        "campusId": "57953bb9-0541-4190-a9de-abf200317f5c"
     }' \
  http://localhost:9130/location-units/libraries

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "d05b8941-a7b3-4519-b450-06d72ca13a0c",
        "name": "Main Uptown Library",
        "code": "UOU/UCC/UUL/M",
        "isActive": true,
        "institutionId": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d",
        "campusId": "57953bb9-0541-4190-a9de-abf200317f5c",
        "libraryId": "b9f519c5-c97c-4c7b-9e42-bc239473370f",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [ "3a40852d-49fd-4df2-a1f9-6e2641a6e91f" ]
    }' \
    http://localhost:9130/locations

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67",
        "name": "Downtown College",
        "code": "DC"
     }' \
  http://localhost:9130/location-units/institutions

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237",
        "name": "Downtown Main Campus",
        "code": "DM",
        "institutionId": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67"
     }' \
  http://localhost:9130/location-units/campuses

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "43364fab-1c38-42ff-aa28-68660f459ef0",
        "name": "Downtown College Library",
        "code": "DL",
        "campusId": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237"
     }' \
  http://localhost:9130/location-units/libraries

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "81582666-305d-4c8e-82cc-061fd00e9c42",
        "name": "Main Downtown Library",
        "code": "DC/DM/DL/M",
        "isActive": true,
        "institutionId": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67",
        "campusId": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237",
        "libraryId": "43364fab-1c38-42ff-aa28-68660f459ef0",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [ "3a40852d-49fd-4df2-a1f9-6e2641a6e91f" ]
    }' \
    http://localhost:9130/locations

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/instance-storage/instances?query=%28title%3D%22Book*%22%29

token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
echo "Book1" from Uptown
curl -w '\n' -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Uptown",
              "title": "Book1",
              "notes": ["Uptown"],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances

echo "Book2" from Uptown
curl -w '\n' -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Uptown",
              "title": "Book2",
              "notes": ["Uptown"],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances

echo "Book1" from Downtown
curl -w '\n' -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Downtown",
              "title": "Book1",
              "notes": ["Downtown"],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances

#curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/instance-storage/instances?query=%28title%3D%22Book1%22%29

#curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/instance-storage/instances

token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
#curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/instance-storage/instances
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/53cf956f-c1df-410b-8bea-27f712cca7c0
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/fcd64ce1-6995-48f0-840e-89ffa2288371
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/758258bc-ecc1-41b8-abca-f7b610822ffd
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/b241764c-1466-4e1d-a028-1a3684a5da87
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/locations/f34d27c6-a8eb-461b-acd6-5dea81771e70
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/libraries/5d78803e-ca04-4b4a-aeae-2c63b924518b
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/campuses/62cf76b7-cca5-4d33-9217-edf42ce1a848
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/location-units/institutions/40ee00ca-a518-4b49-be01-0638d0a4ac57
