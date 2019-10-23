host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "3a028d8d-2fd9-4219-90d4-58a2f50a28be",
        "name": "Unspecified institution",
        "code": "UI"
     }' \
  http://$host/location-units/institutions

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "3a028d8d-2fd9-4219-90d4-58a2f50a28be",
        "name": "Unspecified campus ÆØÅæøåÄÖäö",
        "code": "UC",
        "institutionId": "3a028d8d-2fd9-4219-90d4-58a2f50a28be"
     }' \
  http://$host/location-units/campuses

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "8ade8e78-8cdb-499f-8f45-d8cf8cd3a904",
        "name": "Unspecified library",
        "code": "UL",
        "campusId": "3a028d8d-2fd9-4219-90d4-58a2f50a28be"
     }' \
  http://$host/location-units/libraries

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "c8f57ff4-366f-4c94-8186-d6439fae1d22",
        "name": "Unspecified location",
        "code": "UI/UC/UL/L",
        "isActive": true,
        "institutionId": "3a028d8d-2fd9-4219-90d4-58a2f50a28be",
        "campusId": "3a028d8d-2fd9-4219-90d4-58a2f50a28be",
        "libraryId": "8ade8e78-8cdb-499f-8f45-d8cf8cd3a904",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [ "3a40852d-49fd-4df2-a1f9-6e2641a6e91f" ]
    }' \
    http://$host/locations

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "2117d011-f52b-4efe-ab97-f11d0a4b77e5",
        "name": "Unspecified library record identifier",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types


curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d",
        "name": "West Town College",
        "code": "UOU"
     }' \
  http://$host/location-units/institutions

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "57953bb9-0541-4190-a9de-abf200317f5c",
        "name": "West Town City Campus",
        "code": "UCC",
        "institutionId": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d"
     }' \
  http://$host/location-units/campuses

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "b9f519c5-c97c-4c7b-9e42-bc239473370f",
        "name": "West Town College Library",
        "code": "UUL",
        "campusId": "57953bb9-0541-4190-a9de-abf200317f5c"
     }' \
  http://$host/location-units/libraries

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "d05b8941-a7b3-4519-b450-06d72ca13a0c",
        "name": "West Town Main Library",
        "code": "UOU/UCC/UUL/M",
        "isActive": true,
        "institutionId": "6dab32a8-8c12-441c-ac5e-b2f12be8eb8d",
        "campusId": "57953bb9-0541-4190-a9de-abf200317f5c",
        "libraryId": "b9f519c5-c97c-4c7b-9e42-bc239473370f",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [ "3a40852d-49fd-4df2-a1f9-6e2641a6e91f" ]
    }' \
    http://$host/locations

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67",
        "name": "East Town College",
        "code": "DC"
     }' \
  http://$host/location-units/institutions

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237",
        "name": "East Town Main Campus",
        "code": "DM",
        "institutionId": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67"
     }' \
  http://$host/location-units/campuses

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "43364fab-1c38-42ff-aa28-68660f459ef0",
        "name": "East Town College Library",
        "code": "DL",
        "campusId": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237"
     }' \
  http://$host/location-units/libraries

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "81582666-305d-4c8e-82cc-061fd00e9c42",
        "name": "East Town Main Library",
        "code": "DC/DM/DL/M",
        "isActive": true,
        "institutionId": "542f8cbc-ed9c-45f6-af4e-0bb5c8f24f67",
        "campusId": "0f1c2f1f-6da4-4e7e-948c-c396ac57e237",
        "libraryId": "43364fab-1c38-42ff-aa28-68660f459ef0",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [ "3a40852d-49fd-4df2-a1f9-6e2641a6e91f" ]
    }' \
    http://$host/locations

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "47a65482-f104-45e8-aead-1f12d70dcf32",
        "name": "East Town record identifier",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types

curl -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "9db07825-8035-4d9a-8a41-d59a5f1c337b",
        "name": "West Town record identifier",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types


