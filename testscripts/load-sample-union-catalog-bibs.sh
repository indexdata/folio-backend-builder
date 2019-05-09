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
