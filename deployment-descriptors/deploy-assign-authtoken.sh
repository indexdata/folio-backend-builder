# Locks down module access to authenticated users

workdir=$FOLIO/install-folio-backend

echo Deploy mod-authtoken-1.0.1-SNAPSHOT
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-authtoken-1.4.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules
echo Assign mod-authtoken to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-1.4.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
