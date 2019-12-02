host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "ReShare_VLA",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types/170f6942-fec5-42af-9b5d-6bbba3e0a44a

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "Villanova",
        "code": "VLA",
        "discoveryDisplayName": "Unspecified Villanova service point",
        "pickupLocation": true,
        "holdShelfExpiryPeriod": {
          "duration": 3,
          "intervalId": "Weeks"
        }
      }' \
  http://$host/service-points/170f6942-fec5-42af-9b5d-6bbba3e0a44a

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "943aa176-7612-4e34-a1b9-ea318f92facd",
        "name": "Villanova",
        "code": "VLA"
     }' \
  http://$host/location-units/institutions/943aa176-7612-4e34-a1b9-ea318f92facd

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "c7194757-f541-4dbe-ac90-79434d34562f",
        "name": "Villanova",
        "code": "VLA",
        "institutionId": "943aa176-7612-4e34-a1b9-ea318f92facd"
     }' \
  http://$host/location-units/campuses/c7194757-f541-4dbe-ac90-79434d34562f

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "83a954a3-eca6-4056-9c0c-d8cca429e428",
        "name": "Villanova",
        "code": "VLA",
        "campusId": "c7194757-f541-4dbe-ac90-79434d34562f"
     }' \
  http://$host/location-units/libraries/83a954a3-eca6-4056-9c0c-d8cca429e428

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "42e5ba2f-d935-44f9-87e5-d6e9f01d2fb1",
        "name": "Villanova",
        "code": "VLA/VLA/VLA/VLA",
        "isActive": true,
        "institutionId": "943aa176-7612-4e34-a1b9-ea318f92facd",
        "campusId": "c7194757-f541-4dbe-ac90-79434d34562f",
        "libraryId": "83a954a3-eca6-4056-9c0c-d8cca429e428",
        "primaryServicePoint": "170f6942-fec5-42af-9b5d-6bbba3e0a44a",
        "servicePointIds": [ "170f6942-fec5-42af-9b5d-6bbba3e0a44a" ]
    }' \
    http://$host/locations/42e5ba2f-d935-44f9-87e5-d6e9f01d2fb1


