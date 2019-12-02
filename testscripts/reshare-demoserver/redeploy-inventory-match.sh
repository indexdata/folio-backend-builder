curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-match-2.4.0-SNAPSHOT
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-match.json http://localhost:9130/_/discovery/modules
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-inventory-match/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

