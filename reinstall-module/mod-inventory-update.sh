curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-update-0.0.5-SNAPSHOT

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-inventory-update-0.0.5-SNAPSHOT

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-update.json http://localhost:9130/_/discovery/modules

sleep 2
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-update/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

date
