workdir=$FOLIO/install-folio-backend
echo Unassign mod-users-bl-2.1.1-SNAPSHOT from DIKU
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-bl-2.1.1-SNAPSHOT
echo Unassign mod-users-14.2.2-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-14.2.2-SNAPSHOT
echo Unassign mod-permissions-5.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-permissions-5.0.1-SNAPSHOT
echo Unassign mod-login-4.0.1-SNAPSHOT
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-login-4.0.1-SNAPSHOT
echo Unassign mod-authtoken-1.0.1 
curl -X DELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-authtoken-1.0.1-SNAPSHOT

# mod-permissions must be first, other modules need to write permissions to it
echo Deploy mod-permissions-5.0.1-SNAPSHOT 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-permissions-5.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
$workdir/assign-modules/assign-mod-permissions-to-diku.sh 
echo Deploy mod-users-14.5.0-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-14.5.0-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
$workdir/assign-modules/assign-mod-users-to-diku.sh
echo Deploy mod-login-4.0.1-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-login-4.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
$workdir/assign-modules/assign-mod-login-to-diku.sh 
echo Deploy mod-users-bl-2.2.1-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-bl-2.2.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-users-bl to DIKU
$workdir/assign-modules/assign-mod-users-bl-to-diku.sh 
echo List modules
curl http://localhost:9130/_/discovery/modules
echo List DIKUs modules
curl http://localhost:9130/_/proxy/tenants/diku/modules



