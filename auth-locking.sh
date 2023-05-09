#Locks down module access to authenticated users
echo Deploy mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-authtoken-2.14.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/modules/users-and-auth/DeploymentDescriptor-mod-authtoken.json http://localhost:9130/_/discovery/modules
echo Assign mod-authtoken to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-2.14.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Enter; read

echo mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users-bl/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/modules/users-and-auth/DeploymentDescriptor-mod-users-bl.json http://localhost:9130/_/discovery/modules
echo Assign mod-users-bl to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-7.6.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
