SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR


echo register mod-circulation-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-circulation-storage.json http://localhost:9130/_/discovery/modules
echo assign mod-circulation-storage to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/install-mod-circulation-storage.json http://localhost:9130/_/proxy/tenants/diku/modules
