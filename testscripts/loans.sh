token=$(~/folio/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://localhost:9130/circulation/loans