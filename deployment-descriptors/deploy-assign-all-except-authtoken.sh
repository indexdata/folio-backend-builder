
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-14.2.2-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-permissions-5.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-login-4.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-bl-2.1.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-authtoken-1.0.1-SNAPSHOT

# mod-permissions must be first, other modules need to write permissions to it

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @DeploymentDescriptor-mod-permissions-5.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

../assign-modules/assign-mod-permissions-to-diku.sh 

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @DeploymentDescriptor-mod-users-14.2.2-SNAPSHOT.json http://localhost:9130/_/discovery/modules

../assign-modules/assign-mod-users-to-diku.sh

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @DeploymentDescriptor-mod-login-4.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

../assign-modules/assign-mod-login-to-diku.sh 

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @DeploymentDescriptor-mod-users-bl-2.1.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

../assign-modules/assign-mod-users-bl-to-diku.sh 

curl http://localhost:9130/_/discovery/modules

curl http://localhost:9130/_/proxy/tenants/diku/modules



