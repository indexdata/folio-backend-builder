token=$(~/folio/install-folio-backend/util-scripts/get-token-diku_admin.sh localhost:9130)

curl -w '\n' -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -d '{"query": "query { users { id, username } }"}' http://localhost:9130/graphql

curl -w '\n' -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -d '{"query": "query { groups { group, metadata { createdByUser { username } } } } "}' http://localhost:9130/graphql

#curl -w '\n' -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -d @instances-query.json  http://localhost:9130/graphql

curl -w '\n' -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -d @instance-query-by-id.json  http://localhost:9130/graphql