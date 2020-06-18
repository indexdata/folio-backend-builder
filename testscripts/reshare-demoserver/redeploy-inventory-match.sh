curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-match-3.2.0

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-inventory-match-3.2.0

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-match.json http://localhost:9130/_/discovery/modules

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @/home/ne/git-ole/mod-inventory-match/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

