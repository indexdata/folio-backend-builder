
echo mod-configuration assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-configuration-3.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-notify assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-notify-1.1.6-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

