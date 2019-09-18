token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)

echo Delete existing instances, holdings, items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/item-storage/items
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/holdings-storage/holdings
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://localhost:9130/instance-storage/instances


echo "Book1" from Uptown
instanceId=$(curl -w '\n' -s -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Uptown",
              "title": "Book1",
              "notes": [ { "instanceNoteTypeId": "95f62ca7-5df5-4a51-9890-d0ec3a34665f", "note": "Uptown" }],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances | grep -Po '"id" : "\K.*?(?=".*)')
echo Got instanceId: $instanceId

echo Uptown\'s holdings of "Book1"
holdingsRecordId=$(curl -w '\n' -s -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{
              "instanceId": "' $($instanceId) '",
              "holdingsTypeId" : "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
              "permanentLocationId": "d05b8941-a7b3-4519-b450-06d72ca13a0c",
              "callNumber" : "UPTCN-001"
            }' \
         http://localhost:9130/holdings-storage/holdings )

echo holdingsRecordId: $holdingsRecordId

echo "Book2" from Uptown
instanceId=$(curl -w '\n' -s -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Uptown",
              "title": "Book2",
              "notes": [{ "instanceNoteTypeId": "95f62ca7-5df5-4a51-9890-d0ec3a34665f", "note": "Uptown" }],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances | grep -Po '"id" : "\K.*?(?=".*)')

echo "Book1" from Downtown
instanceId=$(curl -w '\n' -s -X PUT -s -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "Downtown",
              "title": "Book1",
              "notes": [{ "instanceNoteTypeId": "95f62ca7-5df5-4a51-9890-d0ec3a34665f", "note": "Downtown" }],
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
            }' \
         http://localhost:9130/instance-storage-match/instances | grep -Po '"id" : "\K.*?(?=".*)')
