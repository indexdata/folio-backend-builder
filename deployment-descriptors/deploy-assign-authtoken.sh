# Locks down module access to authenticated users

workdir=$FOLIO/install-folio-backend

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-authtoken-1.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

$workdir/assign-modules/assign-mod-authtoken-to-diku.sh
