CONFIG_FILE=$1

if [[ -z "$CONFIG_FILE" ]]; then
  printf "\nPlease provide JSON config file to validate:  ./validate-config.sh myconf.json\n"
  exit
else 
  printf "\nValidating [$CONFIG_FILE]\n"
  parsed=$(jq -r '.' $CONFIG_FILE)
  if [[ -z "$parsed" ]]; then
    printf "\n! Could not parse [$CONFIG_FILE]. Validatition cancelled.\n"
    exit
  fi
fi

error=""

###
echo "* Checking that configurations exist for all selected modules"
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
echo "* Checking that the JVMs that are requested by modules are also defined in the configuration and exist on the file system"
requestedJvms=$(jq -r '.moduleConfigs | unique_by(.deployment.jvm)[].deployment.jvm' "$CONFIG_FILE")
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm $jvm -r '.jvms | any(.symbol == $jvm)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      error="$error\nJVM $jvm is requested by a module but is not defined in 'jvms'"
    else   
     java=$(jq --arg jvm $jvm -r '.jvms[] | select(.symbol == $jvm).home' "$CONFIG_FILE") 
     if [ ! -f "$java" ]; then
       error="$error\nSpecified path to Java [$java] not found on this file system"
     fi
    fi
  fi
done

###
echo "* Checking that Git checkout directories that are referenced by modules are also defined in the configuration and exist on the file system"
requestedCheckoutDirs=$(jq -r '.moduleConfigs | unique_by(.checkedOutTo)[].checkedOutTo' "$CONFIG_FILE")
for dir in $requestedCheckoutDirs; do
  found=$(jq --arg dir "$dir" -r '.checkoutRoots | any(.symbol == $dir)' "$CONFIG_FILE")
  if [[ "$found" != "true" ]]; then 
     error="$error\nCheckout directory $dir is requested by a module but is not defined in 'checkoutRoots'"
  else 
     directory=$(jq --arg dir $dir --arg home $HOME -r '.checkoutRoots[] | select(.symbol == $dir).directory | sub("~";$home)' "$CONFIG_FILE") 
     if [ ! -d $directory ]; then
       error="$error\nSpecified check-out directory [$directory] not found on this file system"
     fi
  fi
done

###
echo "* Checking that selected modules are checked out and built"
selectedModules=$(jq -r '.selectedModules[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $selectedModules; do
  found=$(jq --arg mod "$mod" \
   -r '.moduleConfigs[] | select(.name == $mod)' \
       "$CONFIG_FILE")
  if [[ -n "$found" ]]; then
    checkedOutToSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).checkedOutTo' "$CONFIG_FILE")
    checkedOutTo=$(jq --arg symbol $checkedOutToSymbol --arg home $HOME -r '.checkoutRoots[] | select(.symbol == $symbol).directory | sub("~";$home)' "$CONFIG_FILE")
    methodSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.method' "$CONFIG_FILE")
    pathToJar=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.pathToJar' "$CONFIG_FILE")
    if [[ "$methodSymbol" == "DD" ]]; then
      if [ ! -d "$checkedOutTo/$mod" ]; then
         error="$error\nModule directory [$checkedOutTo/$mod] not found.\n"
      elif [ ! -d "$checkedOutTo/$mod/target" ]; then
         error="$error\n$mod's checkout directory found but it doesn't seem to be built (no /target) [$checkedOutTo/$mod/target]\n" 
      elif [ ! -f "$checkedOutTo/$mod/$pathToJar" ]; then
         error="$error\n$mod's checkout directory with subdir /target found but cannot find the requested jar file [$checkedOutTo/$mod/$pathToJar]\n" 
      elif [ ! -f "$checkedOutTo/$mod/target/ModuleDescriptor.json" ]; then
         error="$error\nFound module directory and jar file but cannot find a module descriptor at  $checkedOutTo/$mod/target/ModuleDescriptor.json\n"
      fi
    fi
  fi
done


### Report
if [[ -z "$error" ]]; then
  printf "\nThe FOLIO config in [$CONFIG_FILE] looks good!\n"
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