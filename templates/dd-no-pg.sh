SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mod=$1
version=$2
jvm=$3
gitdir=$4
jar=$5


ddjson=$(jq --arg mod $mod \
   --arg version $version \
   --arg jvm $jvm \
   --arg gitdir $gitdir \
   --arg jar $jar \
   -r '.srvcId = $mod + "-" + $version |
       .descriptor.exec = $jvm+" -Dport=%p -jar " + $gitdir + "/" + $mod + "/" + $jar + " -Dhttp.port=%p"' \
       $SCRIPT_DIR/DeploymentDescriptor.json)

curl -w '\n' -D - -s -H "Content-type: application/json" -d "$ddjson" http://localhost:9130/_/discovery/modules
#echo enter; read