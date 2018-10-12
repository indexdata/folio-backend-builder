echo mod-inventory-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-storage-13.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-10.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-inventory-1.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-mux assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-mux-2.2.3-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-circulation-storage-6.1.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-circulation-12.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-rtac assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-rtac-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
