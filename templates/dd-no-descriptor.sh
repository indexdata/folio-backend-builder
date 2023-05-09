mod=$1
version=$2

jq --arg mod $mod \
   --arg version $version \
   -r '.srvcId = $mod + "-" + $version' \
       DeploymentDescriptorBare.json
