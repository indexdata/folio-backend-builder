SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR


echo register mod-finance-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-finance-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-finance-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-finance-storage.json http://localhost:9130/_/discovery/modules
echo assign mod-finance-storage to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/install-mod-finance-storage.json http://localhost:9130/_/proxy/tenants/diku/modules

echo register mod-orders-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-orders-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-orders-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-orders-storage.json http://localhost:9130/_/discovery/modules
echo assign mod-orders-storage to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/install-mod-orders-storage.json http://localhost:9130/_/proxy/tenants/diku/modules


