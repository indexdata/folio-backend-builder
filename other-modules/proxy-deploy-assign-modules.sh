

echo mod-configuration proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-configuration deploy 

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-configuration-3.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

echo mod-configuration assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-configuration-3.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

# echo mod-notify proxy

# curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

# echo mod-notify deploy

# curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/DeploymentDescriptor.json http://localhost:9130/_/discovery/modules

# echo mod-notify assign

# curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-notify-1.1.6-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
