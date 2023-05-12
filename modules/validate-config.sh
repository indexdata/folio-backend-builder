SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CFG=$1

if [[ -z "$CFG" ]]; then
  echo "Please provide JSON config file to validate:  ./validate-config.sh myconf.json"
  exit
fi

error=""

###
echo "Checking that configurations exist for all selected modules"
selectedModules=$(jq -r '.selectedModules[] | .name + ":" + .version' $CFG)
for mod in $selectedModules; do
  arr=(${mod//:/ })
  found=$(jq --arg mod ${arr[0]} \
   --arg version ${arr[1]} \
   -r '.moduleConfigs[] | select(.name == $mod and .version == $version)' \
       $CFG)
  if [[ -z "$found" ]]
    then
      error="$error\nNo configuration found for selected module: $mod"
  fi
done

###
echo "Checking that the JVMs requested by modules are defined"
requestedJvms=$(jq -r '.moduleConfigs[].deployment.jvm' $CFG)
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm $jvm -r '.jvms | any(.symbol == $jvm)' $CFG)
    if [[ "$found" != "true" ]]; then 
      error="$error\nJVM $jvm is requested by a module but is not defined in 'jvms'"
    fi
  fi
done

###
echo "Checking that all Git checkout directories referenced by modules are defined."
requestedCheckoutDirs=$(jq -r '.moduleConfigs[].checkedOutTo' $CFG)
for dir in $requestedCheckoutDirs; do
  found=$(jq --arg dir $dir -r '.checkoutRoots | any(.symbol == $dir)' $CFG)
  if [[ "$found" != "true" ]]; then 
     error="$error\nCheckout directory $dir is requested by a module but is not defined in 'checkoutRoots'"
  fi
done

### 
echo "Checking that all deployment types specified by modules are defined."
requestedDeployTypes=$(jq -r '.moduleConfigs[].deployment.type' $CFG)
for ddtype in $requestedDeployTypes; do
  found=$(jq --arg ddtype $ddtype -r '.ddTypes | any(.symbol == $ddtype)' $CFG)
  if [[ "$found" != "true" ]]; then 
     error="$error\nDeployment type $ddtype is specified by a module but is not defined in 'ddTypes'"
  fi
done

### Report
if [[ -z "$error" ]]; then
  echo "Configuration OK"
else 
  printf "\n\nERROR: $error\n"
fi  
