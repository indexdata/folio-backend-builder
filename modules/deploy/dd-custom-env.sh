SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mod=$1
version=$2
jvm=$3
gitdir=$4
jar=$5
env=$6



ddjson=$(jq --arg mod "$mod" \
   --arg version "$version" \
   --arg jvm "$jvm" \
   --arg gitdir "$gitdir" \
   --arg jar "$jar" \
   --argjson env "$env" \
   -r '.srvcId = $mod + "-" + $version |
       .descriptor.exec = $jvm+" -Dport=%p -jar " + $gitdir + "/" + $mod + "/" + $jar + " -Dhttp.port=%p" |
       .descriptor.env = $env ' \
       "$SCRIPT_DIR"/DescriptorTemplate.json)

curl -w '\n' -D - -s -H "Content-type: application/json" -d "$ddjson" http://localhost:9130/_/discovery/modules
#echo enter; read