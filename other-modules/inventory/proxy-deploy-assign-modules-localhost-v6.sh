
echo ### mod-inventory-storage proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo ### mod-inventory-storage deploy 

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-storage-6.0.0-SNAPSHOT.json http://localhost:9130/_/discovery/modules

echo ### mod-inventory-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-storage-6.0.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo ### mod-inventory proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo ### mod-inventory deploy

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-6.0.0-SNAPSHOT.json http://localhost:9130/_/discovery/modules

echo ### mod-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-6.0.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
