CONFIG_FILE=$1

if [[ -z "$CONFIG_FILE" ]]; then
  printf "\nPlease provide JSON config file to validate:  ./validate-config.sh my-folio.json\n"
  exit
else 
  printf "\nValidating [%s]\n\n" "$CONFIG_FILE"
  parsed=$(jq -r '.' "$CONFIG_FILE")
  if [[ -z "$parsed" ]]; then
    printf "\n! Could not validate [%s] due to parsing errors.\n" "$CONFIG_FILE"
    exit
  fi
fi

errors=""

### 
echo "* Checking that major properties are present"
basicModules=$(jq -r '.basicModules' "$CONFIG_FILE")
selectModules=$(jq -r '.selectedModules' "$CONFIG_FILE")
jvm=$(jq -r '.jvms' "$CONFIG_FILE")
checkoutRoots=$(jq -r '.checkoutRoots' "$CONFIG_FILE")
envVars=$(jq -r '.envVars' "$CONFIG_FILE")
tenants=$(jq -r '.jvms' "$CONFIG_FILE")
users=$(jq -r '.jvms' "$CONFIG_FILE")
moduleConfigs=$(jq -r '.jvms' "$CONFIG_FILE")

if [[ "$basicModules" == "null" || "$selectedModules" == "null" || "$jvms" == "null" || "$checkoutRoots" == "null" 
      || "$envVars" == "null" || "$tenants" == "null" || "$users" == "null" || "$moduleConfigs" == "null" ]]; then 
  printf "\n! Could not validate [%s] because one or more basic configuration elements are missing.\n" "$CONFIG_FILE"
  exit
fi  

for name in mod-permissions mod-users mod-login mod-password-validator mod-authtoken mod-configuration mod-users-bl ; do
  found=$(jq --arg name "$name" -r ' .basicModules | any(.name == $name) ' "$CONFIG_FILE")
  if [[ "$found"  != "true" ]]; then
    errors="$errors\nBasic module $name is missing. Users and authentication will not work without it"  
  fi
done

###
echo "* Checking that configurations exist for all basic modules and optional (selected) modules"
selectedModules=$(jq -r '(.basicModules, .selectedModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $selectedModules; do
  found=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -z "$found" ]]
    then
      errors="$errors\nNo configuration found for selected module: $mod"
  fi
done

###
echo "* Checking that the JVMs that are requested by modules are also defined in the configuration and exist on the file system"
requestedJvms=$(jq -r '.moduleConfigs | unique_by(.deployment.jvm)[].deployment.jvm' "$CONFIG_FILE")
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm "$jvm" -r '.jvms | any(.symbol == $jvm)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      errors="$errors\nJVM $jvm is requested by a module but is not defined in 'jvms'"
    else   
     java=$(jq --arg jvm "$jvm" -r '.jvms[] | select(.symbol == $jvm).home' "$CONFIG_FILE")
     if [ ! -f "$java" ]; then
       errors="$errors\nSpecified path to Java [$java] not found on this file system"
     fi
    fi
  fi
done

###
echo "* Checking that Git checkout directories that are referenced by modules are also defined in the configuration and exist on the file system"
requestedCheckoutDirs=$(jq -r '.moduleConfigs | unique_by(.checkedOutTo)[].checkedOutTo' "$CONFIG_FILE")
for dir in $requestedCheckoutDirs; do
  if [[ "$dir" != "null" ]]; then
    found=$(jq --arg dir "$dir" -r '.checkoutRoots | any(.symbol == $dir)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      errors="$errors\nCheckout directory $dir is requested by a module but is not defined in 'checkoutRoots'"
    else 
      directory=$(jq --arg dir "$dir" --arg home "$HOME" -r '.checkoutRoots[] | select(.symbol == $dir).directory | sub("~";$home)' "$CONFIG_FILE")
      if [ ! -d "$directory" ]; then
        errors="$errors\nSpecified check-out directory [$directory] not found on this file system"
      fi
    fi
  fi
done

###
echo "* Checking that basic and selected modules are checked out and built"
modules=$(jq -r ' (.selectedModules, .basicModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $modules ; do
  printf "\n  - $mod"
  found=$(jq --arg mod $mod -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -n "$found" ]]; then
    checkedOutToSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).checkedOutTo' "$CONFIG_FILE")
    methodSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.method' "$CONFIG_FILE")
    if [[ "$checkedOutToSymbol" == "null" || "$methodSymbol" == "null"  ]]; then
      if [[ "$checkedOutToSymbol" == "null" ]]; then
        errors="$errors\nMissing configuration for $mod: 'checkedOutTo'.\n"
      fi
      if [[ "$methodSymbol" == "null" ]]; then
        errors="$errors\nMissing configuration for $mod: 'deployment.method'.\n"
      fi
    else 
      checkedOutTo=$(jq --arg symbol "$checkedOutToSymbol" --arg home "$HOME" -r '.checkoutRoots[] | select(.symbol == $symbol).directory | sub("~";$home)' "$CONFIG_FILE")
      if [[ ! -d "$checkedOutTo/$mod" ]]; then
        errors="$errors\nNo check-out of $mod found at $checkedOutTo/$mod\n"
      fi
      if [[ "$methodSymbol" == "DD" ]]; then
        pathToJar=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.pathToJar' "$CONFIG_FILE")
        jvm=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.jvm' "$CONFIG_FILE")
        env=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.env' "$CONFIG_FILE")
        if [ "$pathToJar" == "null" ]; then
          errors="$errors\nMissing configuration for $mod: 'deployment.pathToJar'.\n"
        fi      
        if [ "$jvm" == "null" ]; then
          errors="$errors\nMissing configuration for $mod: 'deployment.jvm'.\n"
        fi 
        if [ "$env" == "null" ]; then
          errors="$errors\nMissing configuration for $mod: 'deployment.env'.\n"
        fi 
        if [[ -d "$checkedOutTo/$mod" && "$pathToJar" != "null" ]]; then
          if [ ! -d "$checkedOutTo/$mod" ]; then
            errors="$errors\nModule directory [$checkedOutTo/$mod] not found.\n"
          elif [ ! -d "$checkedOutTo/$mod/target" ]; then
            errors="$errors\n$mod's checkout directory found but it doesn't seem to be built (no /target) [$checkedOutTo/$mod/target]\n"
          elif [ ! -f "$checkedOutTo/$mod/$pathToJar" ]; then
            errors="$errors\n$mod's checkout directory with subdir /target found but cannot find the requested jar file [$checkedOutTo/$mod/$pathToJar]\n"
          elif [ ! -f "$checkedOutTo/$mod/target/ModuleDescriptor.json" ]; then
            errors="$errors\nFound module directory and jar file but cannot find a module descriptor at  $checkedOutTo/$mod/target/ModuleDescriptor.json\n"
          fi
        fi
      fi
      specifiedVersion=$(jq --arg name "$mod" -r '(.basicModules, .selectedModules)[] | select(.name == $name) | .version ' "$CONFIG_FILE")
      if [[ -d "$checkedOutTo/$mod" &&  "$specifiedVersion" != "null" ]]; then
        installedVersion=$(jq -r '.id' "$checkedOutTo/$mod/target/ModuleDescriptor.json")
        if [ "$installedVersion" != "$mod-$specifiedVersion" ]; then
          printf "  (config:%s-%s != installed:%s)"  "$mod"  "$specifiedVersion" "$installedVersion" 
        fi
      fi  
    fi
    permissions=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).permissions' "$CONFIG_FILE")
    if [[ "$permissions" == "null" ]]; then
      errors="$errors\nMissing configuration for $mod: 'permissions'.\n"
    fi
  fi
done

### Report
if [[ -z "$errors" ]]; then
  printf "\n\nConfiguration [%s] looks good!\n\n" "$CONFIG_FILE"
else 
  printf "\n\nERROR: %s\n" "$errors"
fi  
