curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-shared-index-0.0.1-SNAPSHOT

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-shared-index-0.0.1-SNAPSHOT

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @../inventory/DeploymentDescriptor-mod-shared-index.json http://localhost:9130/_/discovery/modules

sleep 2
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-shared-index-0.0.1-SNAPSHOT"}'  http://localhost:9130/_/proxy/tenants/diku/modules

date
