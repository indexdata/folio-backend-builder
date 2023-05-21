SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
MOD=$1
PROJECT=$2
source "$workdir/lib/ConfigReader.sh"

dd=$(makeDeploymentDescriptor "$MOD" "$PROJECT")
id=$(moduleDescriptorId "$MOD" "$PROJECT")
curl -X DELETE "http://localhost:9130/_/discovery/modules/$id"
curl -w '\n' -D - -s -H "Content-type: application/json" -d "$dd" http://localhost:9130/_/discovery/modules
