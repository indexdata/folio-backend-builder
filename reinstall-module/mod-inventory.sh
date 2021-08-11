curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-17.1.0-SNAPSHOT

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-inventory-17.1.0-SNAPSHOT

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules

sleep 2
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

date
