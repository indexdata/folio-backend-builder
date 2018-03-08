# ui module descriptors

uidesc=$FOLIO/folio-testing-platform-cut-down/ModuleDescriptors

echo Enable ui inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/inventory.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_inventory-1.0.2000114"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Enable ui users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/users.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_users-2.12.1000220"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Enable ui core

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/stripes-core.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_stripes-core-2.9.2000199"}' http://localhost:9130/_/proxy/tenants/diku/modules
