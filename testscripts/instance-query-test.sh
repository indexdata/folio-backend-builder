token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/inventory/instances?query=\(id%3D69640328-788e-43fc-9c3c-af39e243f3b7\)

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/inventory/instances?query=\(indexTitle%3D%3D%22tut__tut____________________________________________________________________1996__74____puffin_books%22\)
