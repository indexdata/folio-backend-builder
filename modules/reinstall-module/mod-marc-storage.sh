curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-marc-storage-0.0.5-SNAPSHOT

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-marc-storage-0.0.5-SNAPSHOT

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @../inventory/DeploymentDescriptor-mod-marc-storage.json http://localhost:9130/_/discovery/modules

sleep 2
echo Assign mod-marc-storage to diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-marc-storage-0.0.5-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules


date
