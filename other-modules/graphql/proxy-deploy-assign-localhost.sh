echo mod-graphql proxy

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-graphql/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-graphql deploy 

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-graphql/ExternalDeploymentDescriptor.json http://localhost:9130/_/discovery/modules

echo mod-graphql assign

curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-graphql-0.1.0"}' http://localhost:9130/_/proxy/tenants/diku/modules

#cd $FOLIO/mod-graphql

#yarn start
