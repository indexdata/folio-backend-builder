
echo mod-configuration deploy 

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-configuration.json http://localhost:9130/_/discovery/modules

echo mod-notify deploy

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/DeploymentDescriptor.json http://localhost:9130/_/discovery/modules

