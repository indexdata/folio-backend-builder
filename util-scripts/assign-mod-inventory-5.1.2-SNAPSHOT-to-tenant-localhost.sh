curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-5.1.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/$1/modules
