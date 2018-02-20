# ui module descriptors

uidesc=$FOLIO/folio-testing-platform-cut-down/ModuleDescriptors

echo Enable ui inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/inventory.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_inventory-1.0.0"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Enable ui users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/users.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_users-2.10.100048"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Enable ui items

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/items.json http://localhost:9130/_/proxy/modules

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_items-1.11.10009"}' http://localhost:9130/_/proxy/tenants/diku/modules
