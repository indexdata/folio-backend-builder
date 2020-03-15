# ui module descriptors
log="proxy-enable-ui-modules.log"
rm -f $log

echo `date` > $log

uidesc=$FOLIO/folio-testing-platform-cut-down/ModuleDescriptors

echo Enable ui inventory
curl -s -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/inventory.json http://localhost:9130/_/proxy/modules >> $log

curl -s -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_inventory-1.0.3000235"}' http://localhost:9130/_/proxy/tenants/diku/modules  >> $log

echo Enable ui users
curl -s -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/users.json http://localhost:9130/_/proxy/modules >> $log

curl -s -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_users-2.12.2000338"}' http://localhost:9130/_/proxy/tenants/diku/modules >> $log

echo Enable ui core

curl -s -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/stripes-core.json http://localhost:9130/_/proxy/modules >> $log

curl -s -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_stripes-core-2.10.1000277"}' http://localhost:9130/_/proxy/tenants/diku/modules >> $log

echo Enable ui search

curl -s -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$uidesc/search.json http://localhost:9130/_/proxy/modules  >> $log

curl -s -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "folio_search-1.1.100082"}' http://localhost:9130/_/proxy/tenants/diku/modules  >> $log
