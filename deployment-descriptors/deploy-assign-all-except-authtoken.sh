workdir=$FOLIO/install-folio-backend
echo Unassign mod-users-bl-2.2.1-SNAPSHOT from DIKU
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-bl-2.2.1-SNAPSHOT
echo Unassign mod-users-14.5.0-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-14.5.0-SNAPSHOT
echo Unassign mod-permissions-5.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-permissions-5.0.1-SNAPSHOT
echo Unassign mod-login-4.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-login-4.0.1-SNAPSHOT
echo Unassign mod-authtoken-1.0.1 
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-authtoken-1.4.1-SNAPSHOT

# mod-permissions must be first, other modules need to write permissions to it
echo Deploy mod-permissions-5.0.1-SNAPSHOT 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-permissions-5.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-permissions-5.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Deploy mod-users-14.5.0-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-14.5.0-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-14.5.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Deploy mod-login-4.0.1-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-login-4.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-login-4.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Deploy mod-users-bl-2.2.1-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-bl-2.2.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-users-bl to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-2.2.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Assign internal module to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "okapi-2.14.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo List modules
curl http://localhost:9130/_/discovery/modules
echo List DIKUs modules
curl http://localhost:9130/_/proxy/tenants/diku/modules



