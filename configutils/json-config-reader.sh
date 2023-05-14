selectedModules() {
  jq -r '.selectedModules[] | select(.name != null)' $1 
}

moduleConfig() {
  jq --arg name $1 --arg version $2 -r '.moduleConfigs[] | select(.name == $name and .version == $version)' $3
}

moduleVersionByName() {
  jq --arg name $1 -r '.selectedModules[] | select(.name == $name).version' $2
}

checkoutRoot() {
  jq --arg dir $1 -r '.checkoutRoots[] | select(.symbol == $dir).directory' $2
}

jvm() {
  jq --arg jvm $1 -r '.jvms[] | select(.symbol == $jvm).home' $2
}

baseDir() {
  symbol=$(moduleConfig $1 $2 $3 | jq -r '.checkedOutTo')
  dir=$(checkoutRoot $symbol $3)
  if [[ "$dir" =~ ^\~.* ]]
    then
      echo "$HOME${dir#\~}"
    else 
      echo "${dir#null}"
  fi
}

javaHome() {
  symbol=$(moduleConfig $1 $2 $3 | jq -r '.deployment.jvm')
  found=$(jvm "$symbol" "$3")
  echo "${found#null}"
}

pathToJar() {
  moduleConfig $1 $2 $3 | jq -r '.deployment.pathToJar'  
}

deploymentMethod() {
  moduleConfig "$1" "$2" "$3" | jq -r '.deployment.method'
}

env() {
  jq --arg name $1 --arg version $2 -r ' 
    if (.moduleConfigs[] | select(.name == $name and .version == $version).deployment.env | type) == "array" then
      .moduleConfigs[] | select(.name == $name and .version == $version).deployment.env
    else
      (.moduleConfigs[] | select(.name == $name and .version == $version).deployment.env) as $symbol 
      | .envVars[] | select(.symbol == $symbol).env 
    end' $3
}

installParameters() {
  install=$(moduleConfig $1 $2 $3 | jq -r '.install')
  if [[ ! -z "$install" ]]; then
     found=$(echo $install | jq -r '.tenantParameters')
     echo "${found#null}"
  fi
}

permissions() {
  moduleConfig $1 $2 $3 | jq -r '.permissions[]'  
}

users() {
  jq '.users[].user' $1   
}

credentials() {
  jq '.users[].credentials' $1   
}

tenants() {
  jq '.tenants[]' $1
}

