host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "ReShare_MVS",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types/04d081a1-5c52-4b84-8962-949fc5f6773c

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "Millersville",
        "code": "MVS",
        "discoveryDisplayName": "Millersville",
        "pickupLocation": true,
        "holdShelfExpiryPeriod": {
          "duration": 3,
          "intervalId": "Weeks"
        }
      }' \
  http://$host/service-points/76d17981-f8f7-4dd5-94b7-4e55d84dde8f

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "b4578dbc-4dd9-4ac1-9c01-8a13f65aa95e",
        "name": "Millersville",
        "code": "MVS"
     }' \
  http://$host/location-units/institutions/b4578dbc-4dd9-4ac1-9c01-8a13f65aa95e

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "93678933-8cf2-4c98-a665-045ed466e26c",
        "name": "Millersville",
        "code": "MVS",
        "institutionId": "b4578dbc-4dd9-4ac1-9c01-8a13f65aa95e"
     }' \
  http://$host/location-units/campuses/93678933-8cf2-4c98-a665-045ed466e26c

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "90c91643-303c-4379-9fbb-7609a1847096",
        "name": "Millersville",
        "code": "MVS",
        "campusId": "93678933-8cf2-4c98-a665-045ed466e26c"
     }' \
  http://$host/location-units/libraries/90c91643-303c-4379-9fbb-7609a1847096

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "004c14d3-fb87-40fc-b4db-9e91738b4f1b",
        "name": "Millersville",
        "code": "MVS/MVS/MVS/MVS",
        "isActive": true,
        "institutionId": "b4578dbc-4dd9-4ac1-9c01-8a13f65aa95e",
        "campusId": "93678933-8cf2-4c98-a665-045ed466e26c",
        "libraryId": "90c91643-303c-4379-9fbb-7609a1847096",
        "primaryServicePoint": "76d17981-f8f7-4dd5-94b7-4e55d84dde8f",
        "servicePointIds": [ "76d17981-f8f7-4dd5-94b7-4e55d84dde8f" ]
    }' \
    http://$host/locations/004c14d3-fb87-40fc-b4db-9e91738b4f1b

