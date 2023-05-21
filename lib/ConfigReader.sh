selectedModules() {
  jq -r '.selectedModules[] | select(.name != null)' "$1"
}

moduleConfig() {
  jq --arg name "$1"  -r '.moduleConfigs[] | select(.name == $name)' "$2"
}

checkoutRoot() {
  jq --arg dir "$1" -r '.checkoutRoots[] | select(.symbol == $dir).directory | sub("~";env.HOME)' "$2"
}

jvm() {
  jq --arg jvm "$1" -r '.jvms[] | select(.symbol == $jvm).home | sub("~";env.HOME)' "$2"
}

baseDir() {
  symbol=$(moduleConfig "$1" "$2" | jq -r '.checkedOutTo')
  dir=$(checkoutRoot "$symbol" "$2")
  echo "${dir/#null}"
}

javaHome() {
  symbol=$(moduleConfig "$1" "$2"  | jq -r '.deployment.jvm')
  found=$(jvm "$symbol" "$2")
  echo "${found#null}"
}

gitHost() {
  symbol=$(moduleConfig "$1" "$2"  | jq -r '.gitHost')
}

pathToJar() {
  moduleConfig "$1" "$2" | jq -r '.deployment.pathToJar'
}

deploymentMethod() {
  moduleConfig "$1" "$2" | jq -r '.deployment.method'
}

env() {
  jq --arg name "$1" -r '
    if (.moduleConfigs[] | select(.name == $name).deployment.env | type) == "array" then
      .moduleConfigs[] | select(.name == $name).deployment.env
    else
      (.moduleConfigs[] | select(.name == $name).deployment.env) as $symbol
      | .envVars[] | select(.symbol == $symbol).env 
    end' "$2"
}

installParameters() {
  install=$(moduleConfig "$1" "$2" | jq -r '.install')
  if [[ -n "$install" ]]; then
     found=$(echo "$install" | jq -r '.tenantParameters')
     echo "${found#null}"
  fi
}

permissions() {
  moduleConfig "$1" "$2" | jq -r '.permissions[]'
}

users() {
  jq '.users[].user' "$1"
}

credentials() {
  jq '.users[].credentials' "$1"
}

tenants() {
  jq '.tenants[]' "$1"
}

## Will assemble a deployment descriptor with provided module name and id
## Requires that the module is checked out to look for the MD id.
makeDeploymentDescriptor() {
  moduleName="$1"
  configFile="$2"
  method=$(deploymentMethod "$moduleName" "$configFile")
  if [[ "$method" == "DD" ]]; then
    jvm=$(javaHome "$moduleName" "$configFile")
    baseDir=$(baseDir "$moduleName" "$configFile")
    mdId=$(moduleDescriptorId "$moduleName" "$configFile")
    jar=$(pathToJar "$moduleName" "$configFile")
    env=$(env "$moduleName" "$configFile")
    echo '{ "srvcId": "'"$mdId"'",  "nodeId": "localhost",
            "descriptor": {
              "exec": "'"$jvm"/bin/java' -Dport=%p -jar '"$baseDir"'/'"$moduleName"'/'"$jar"' -Dhttp.port=%p",
              "env": '"$env"' }}'
  fi
}

## Reads the module descriptor so requires that the module is checked out.
moduleDescriptorId() {
  moduleName=$1
  configFile=$2
  baseDir=$(baseDir "$moduleName" "$configFile")
  mdPath="$baseDir/$moduleName/target/ModuleDescriptor.json"
  if [[ -f "$mdPath" ]]; then
    jq -r '.id' "$mdPath"
 else
    echo ""
 fi
}

