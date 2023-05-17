selectedModules() {
  jq -r '.selectedModules[] | select(.name != null)' "$1"
}

moduleConfig() {
  jq --arg name "$1"  -r '.moduleConfigs[] | select(.name == $name)' "$2"
}

checkoutRoot() {
  jq --arg dir "$1" -r '.checkoutRoots[] | select(.symbol == $dir).directory' "$2"
}

jvm() {
  jq --arg jvm "$1" -r '.jvms[] | select(.symbol == $jvm).home' "$2"
}

baseDir() {
  symbol=$(moduleConfig "$1" "$2" | jq -r '.checkedOutTo')
  dir=$(checkoutRoot "$symbol" "$2")
  if [[ "$dir" =~ ^\~.* ]]
    then
      echo "$HOME${dir#\~}"
    else 
      echo "${dir#null}"
  fi
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

