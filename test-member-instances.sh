token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

echo "Book 1" from library 1
curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "test",
              "title": "Book 1",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "612a1928-e476-42bf-9350-1f6d28ef410d"
            }' \
         http://localhost:9130/union-catalog/member-instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

echo "Book 2" from library 1
curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "test",
              "title": "Book 2",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "612a1928-e476-42bf-9350-1f6d28ef410d"
            }' \
         http://localhost:9130/union-catalog/member-instances

echo "Book 1" from library 2
curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "test",
              "title": "Book 1",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "b20ec669-3b35-499e-90f6-c901149f7d32"
            }' \
         http://localhost:9130/union-catalog/member-instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

echo "Book 2" from library 2
curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "test",
              "title": "Book 2",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "b20ec669-3b35-499e-90f6-c901149f7d32"
            }' \
         http://localhost:9130/union-catalog/member-instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

echo "Book 3" from library 2
curl -w '\n' -X POST -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "id": "a5a26304-27d7-41e9-9a39-25e5fdf0a00b",
              "source": "test",
              "title": "Book 3",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "b20ec669-3b35-499e-90f6-c901149f7d32"
            }' \
         http://localhost:9130/union-catalog/member-instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

curl -w '\n' -X PUT -D - \
         -H "Content-type: application/json" \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         -d '{ 
              "source": "test-modified",
              "title": "Book 3",
              "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
              "libraryId": "b20ec669-3b35-499e-90f6-c901149f7d32"
            }' \
         http://localhost:9130/union-catalog/member-instances/a5a26304-27d7-41e9-9a39-25e5fdf0a00b

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances

curl -w '\n' -X DELETE -D - \
         -H "X-Okapi-Tenant: diku" \
         -H "X-Okapi-Token: $token" \
         http://localhost:9130/union-catalog/member-instances

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/union-catalog/member-instances
