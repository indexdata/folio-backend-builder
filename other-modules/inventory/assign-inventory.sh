echo mod-inventory-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-storage-12.6.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-9.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-inventory assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-inventory-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-mux assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-mux-2.2.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation-storage assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-circulation-storage-5.0.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-circulation-10.4.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
