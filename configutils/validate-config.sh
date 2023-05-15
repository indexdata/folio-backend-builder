CONFIG_FILE=$1

if [[ -z "$CONFIG_FILE" ]]; then
  echo "Please provide JSON config file to validate:  ./validate-config.sh myconf.json"
  exit
else 
  echo "Validating $CONFIG_FILE"
fi

error=""

###
echo "Checking that configurations exist for all selected modules"
selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $selectedModules; do
  found=$(jq --arg mod "$mod" \
   -r '.moduleConfigs[] | select(.name == $mod)' \
       "$CONFIG_FILE")
  if [[ -z "$found" ]]
    then
      error="$error\nNo configuration found for selected module: $mod"
  fi
done

###
echo "Checking that the JVMs requested by modules are defined"
requestedJvms=$(jq -r '.moduleConfigs[].deployment.jvm' "$CONFIG_FILE")
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm $jvm -r '.jvms | any(.symbol == $jvm)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      error="$error\nJVM $jvm is requested by a module but is not defined in 'jvms'"
    fi
  fi
done

###
echo "Checking that all Git checkout directories referenced by modules are defined."
requestedCheckoutDirs=$(jq -r '.moduleConfigs[].checkedOutTo' "$CONFIG_FILE")
for dir in $requestedCheckoutDirs; do
  found=$(jq --arg dir "$dir" -r '.checkoutRoots | any(.symbol == $dir)' "$CONFIG_FILE")
  if [[ "$found" != "true" ]]; then 
     error="$error\nCheckout directory $dir is requested by a module but is not defined in 'checkoutRoots'"
  fi
done

### Report
if [[ -z "$error" ]]; then
  echo "Configuration OK"
else 
  printf "\n\nERROR: $error\n"
fi  


# Other possible validations for each module: 
#    - It has "name", 
#             "version", 
#             "checkedOutTo", 
#             "requiredBy", 
#             "deployment", 
#             "deployment.method"
#      - if "deployment.method" is not "DOCKER", that is has "jvm", "pathToJar"
#        - if "deployment.method" is DD-PG or DD-PG-KAFKA, that it has "pgHost"
#      - the jar file exists 
#      - the descriptor JSONs exist