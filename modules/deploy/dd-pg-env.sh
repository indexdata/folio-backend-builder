SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mod=$1
version=$2
jvm=$3
gitdir=$4
jar=$5
host=$6


ddjson=$(jq --arg mod $mod \
   --arg version $version \
   --arg jvm $jvm \
   --arg gitdir $gitdir \
   --arg jar $jar \
   --arg host $host \
   --argjson env '[
                     { "name": "DB_HOST", "value": "postgres"},
                     { "name": "DB_PORT", "value": 5432},
                     { "name": "DB_USERNAME", "value": "folio_admin" },
                     { "name": "DB_PASSWORD", "value": "folio_admin" },
                     { "name": "DB_DATABASE", "value": "okapi_modules" }
                   ]' \
   -r '.descriptor.env = $env |
       .srvcId = $mod + "-" + $version |
       .descriptor.exec = $jvm+" -Dport=%p -Dstorage=postgres -jar " + $gitdir + "/" + $mod + "/" + $jar + " -Dhttp.port=%p" |
       (.descriptor.env[] | select(.name=="DB_HOST") | .value) |= $host'  \
       $SCRIPT_DIR/DescriptorTemplate.json)

curl -w '\n' -D - -s -H "Content-type: application/json" -d "$ddjson" http://localhost:9130/_/discovery/modules
#echo enter; read