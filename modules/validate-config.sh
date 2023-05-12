
error=""

###
echo "Checking that configurations exist for all selected modules"
selectedModules=$(jq -r '.selectedModules[] | .name + ":" + .version' folio-one.json)
for mod in $selectedModules; do
  arr=(${mod//:/ })
  found=$(jq --arg mod ${arr[0]} \
   --arg version ${arr[1]} \
   -r '.moduleConfigs[] | select(.name == $mod and .version == $version)' \
       folio-one.json)
  if [[ -z "$found" ]]
    then
      error="$error\nNo configuration found for selected module: $mod"
  fi
done

###
echo "Checking that the JVMs requested by modules are defined"
requestedJvms=$(jq -r '.moduleConfigs[].deployment.jvm' folio-one.json)
for jvm in $requestedJvms; do
  found=$(jq --arg jvm $jvm -r '.jvms | any(.symbol == $jvm)' folio-one.json)
  if [[ "$found" != "true" ]]; then 
     error="$error\nJVM $jvm is requested by a module but is not defined in 'jvms'"
  fi
done

###
echo "Checking that all Git checkout directories referenced by modules are defined."
requestedCheckoutDirs=$(jq -r '.moduleConfigs[].checkedOutTo' folio-one.json)
for dir in $requestedCheckoutDirs; do
  found=$(jq --arg dir $dir -r '.checkoutRoots | any(.symbol == $dir)' folio-one.json)
  if [[ "$found" != "true" ]]; then 
     error="$error\nCheckout directory $dir is requested by a module but is not defined in 'checkoutRoots'"
  fi
done

### 
echo "Checking that all deployment types specified by modules are defined."
requestedDeployTypes=$(jq -r '.moduleConfigs[].deployment.type' folio-one.json)
for ddtype in $requestedDeployTypes; do
  found=$(jq --arg ddtype $ddtype -r '.ddTypes | any(.symbol == $ddtype)' folio-one.json)
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
