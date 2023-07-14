selectedModules() {
  jq -r '.selectedModules[]' "$1"
}

basicModules() {
  jq -r '.basicModules[]' "$1"
}

moduleConfigs() {
  jq -r '.moduleConfigs[]' "$1"
}

moduleConfig() {
  jq --arg name "$1"  -r '.moduleConfigs[] | select(.name == $name)' "$2"
}

module() {
  jq --arg name "$1"  -r '(.selectedModules,.basicModules)[] | select(.name == $name)' "$2"
}

moduleRepo() {
  repo=$(module "$1" "$2" | jq -r '.repo')
  echo "${repo#null}"
}

moduleRepoOrDefault() {
  repo=$(module "$1" "$2" | jq -r '.repo')
  repo=${repo#null}
  if [[ -n "$repo" ]]; then
    echo "$repo"
  else
    repo=$(moduleConfig "$1" "$2" | jq -r '.gitHost')
    echo "${repo/#null/"https://github.com/folio-org"}"
  fi
}

moduleVersion()  {
  module "$1" "$2" | jq -r '(.version)'
}

moduleSourceSymbol() {
  module "$1" "$2" | jq -r '(.sourceDirectory)'
}

alternativeDirectories() {
  jq  -r '.alternativeDirectories//""' "$1"
}

alternativeDirectory() {
  jq --arg symbol "$1" -r '.alternativeDirectories[] | select(.symbol == $symbol).directory | sub("~";env.HOME)' "$2"
}

jvm() {
  jq --arg jvm "$1" -r '.jvms[] | select(.symbol == $jvm).home | sub("~";env.HOME)' "$2"
}

jvms() {
  jq -r '.jvms' "$1"
}

envVars() {
  jq -r '.envVars' "$1"
}

sourceDirectory() {
  jq -r '. | if has("sourceDirectory") then (.sourceDirectory | sub("~";env.HOME)) else "" end' "$1"
}

moduleDirectory() {
  symbol=$(module "$1" "$2" | jq -r '.sourceDirectory')
  if [[ "$symbol" == "null" ]]; then
    sourceDirectory "$2"
  else
    alternativeDirectory "$symbol" "$2"
  fi
}

javaHome() {
  symbol=$(moduleConfig "$1" "$2"  | jq -r '.deployment.jvm')
  found=$(jvm "$symbol" "$2")
  echo "${found#null}"
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
    sourceDirectory=$(moduleDirectory "$moduleName" "$configFile")
    mdId=$(moduleDescriptorId "$moduleName" "$configFile")
    jar=$(pathToJar "$moduleName" "$configFile")
    env=$(env "$moduleName" "$configFile")
    echo '{ "srvcId": "'"$mdId"'",  "nodeId": "localhost",
            "descriptor": {
              "exec": "'"$jvm"/bin/java' -Xms64M -Xmx192M -Dport=%p -jar '"$sourceDirectory"'/'"$moduleName"'/'"$jar"' -Dhttp.port=%p",
              "env": '"$env"' }}'
  fi
}

## Reads the module descriptor so requires that the module is checked out.
moduleDescriptorId() {
  moduleName=$1
  configFile=$2
  sourceDirectory=$(moduleDirectory "$moduleName" "$configFile")
  mdPath="$sourceDirectory/$moduleName/target/ModuleDescriptor.json"
  if [[ -f "$mdPath" ]]; then
    jq -r '.id' "$mdPath"
 else
    echo ""
 fi
}

