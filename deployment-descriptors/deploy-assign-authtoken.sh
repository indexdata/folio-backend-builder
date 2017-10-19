# Locks down module access to authenticated users

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @DeploymentDescriptor-mod-authtoken-1.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

../assign-modules/assign-mod-authtoken-to-diku.sh
