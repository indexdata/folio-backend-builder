
echo mod-inventory-storage proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-inventory-storage deploy 

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-storage.json http://localhost:9130/_/discovery/modules

echo mod-inventory-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-storage-11.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-inventory deploy

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules

echo mod-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-8.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-inventory proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-codex-inventory deploy

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-inventory.json http://localhost:9130/_/discovery/modules

echo mod-codex-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-inventory-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-mux proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-mux/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-codex-mux deploy

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-mux.json http://localhost:9130/_/discovery/modules

echo mod-codex-mux assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-mux-2.2.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
