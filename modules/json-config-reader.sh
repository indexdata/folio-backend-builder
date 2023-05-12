selectedModules() {
  jq -r '.selectedModules[]' $1 
}

moduleConfig() {
  jq --arg name $1 --arg version $2 -r '.moduleConfigs[] | select(.name == $name and .version == $version)' $3
}

checkoutRoot() {
  jq --arg dir $1 -r '.checkoutRoots[] | select(.symbol == $dir).directory' $2
}

jvm() {
  jq --arg jvm $1 -r '.jvms[] | select(.symbol == $jvm).home' $2
}

ddScript() {
  jq --arg ddType $1 -r '.ddTypes[] | select(.symbol == $ddType).script' $2
}

baseDir() {
  symbol=$(moduleConfig $1 $2 $3 | jq -r '.checkedOutTo')
  dir=$(checkoutRoot $symbol $3)
  if [[ "$dir" =~ ^\~\/.* ]]
    then
      echo "$HOME/${dir:2:100}"
    else 
      echo $dir
  fi
}

javaHome() {
  symbol=$(moduleConfig $1 $2 $3 | jq -r '.deployment.jvm')
  jvm $symbol $3
}

pathToJar() {
  moduleConfig $1 $2 $3 | jq -r '.deployment.pathToJar'  
}

pgHost() {
  moduleConfig $1 $2 $3 | jq -r '.deployment.pgHost'  
}

deploymentType() {
  moduleConfig $1 $2 $3 | jq -r '.deployment.type'
}

deployScript() {
  symbol=$(moduleConfig $1 $2 $3 | jq -r '.deployment.type')
  ddScript $symbol $3  
}

deploymentDescriptor() {
  moduleConfig $1 $2 $3 | jq -r '.deployment.descriptor'
}

installParameters() {
  install=$(moduleConfig $1 $2 $3 | jq -r '.install')
  if [[ ! -z "$install" ]]; then
     echo $install | jq -r '.tenantParameters'
  fi
}

permissions() {
  moduleConfig $1 $2 $3 | jq -r '.permissions[]'  
}

