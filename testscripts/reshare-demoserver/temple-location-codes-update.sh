host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "ReShare_TEU",
        "source": "RESHARE"
    }' \
    http://$host/identifier-types/17bb9b44-0063-44cc-8f1a-ccbb6188060b

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "name": "Temple",
        "code": "TEU",
        "discoveryDisplayName": "Temple",
        "pickupLocation": true,
        "holdShelfExpiryPeriod": {
          "duration": 3,
          "intervalId": "Weeks"
        }
      }' \
  http://$host/service-points/efb9addf-caf4-4052-bb17-135cb4aa0594

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "05770b43-8f13-41e3-9ffd-8c13ae570d18",
        "name": "Temple",
        "code": "TEU"
     }' \
  http://$host/location-units/institutions/05770b43-8f13-41e3-9ffd-8c13ae570d18

curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "e4cb3320-adba-4412-98fe-1f8576ec50db",
        "name": "Temple",
        "code": "TEU",
        "institutionId": "05770b43-8f13-41e3-9ffd-8c13ae570d18"
     }' \
  http://$host/location-units/campuses/e4cb3320-adba-4412-98fe-1f8576ec50db


curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{ 
        "id": "bb973f8b-096d-4a30-9434-5e094facdc54",
        "name": "Temple",
        "code": "TEU",
        "campusId": "e4cb3320-adba-4412-98fe-1f8576ec50db"
     }' \
  http://$host/location-units/libraries/bb973f8b-096d-4a30-9434-5e094facdc54


curl -w '\n' -X PUT -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: diku" \
  -H "X-Okapi-Token: $token" \
  -d '{
        "id": "87038e41-0990-49ea-abd9-1ad00a786e45",
        "name": "Temple",
        "code": "TEU/TEU/TEU/TEU",
        "isActive": true,
        "institutionId": "05770b43-8f13-41e3-9ffd-8c13ae570d18",
        "campusId": "e4cb3320-adba-4412-98fe-1f8576ec50db",
        "libraryId": "bb973f8b-096d-4a30-9434-5e094facdc54",
        "primaryServicePoint": "efb9addf-caf4-4052-bb17-135cb4aa0594",
        "servicePointIds": [ "efb9addf-caf4-4052-bb17-135cb4aa0594" ]
    }' \
    http://$host/locations/87038e41-0990-49ea-abd9-1ad00a786e45
