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

Errors=()

### 
echo "* Checking that major properties are present"
basicModules=$(jq -r '.basicModules' "$CONFIG_FILE")
selectedModules=$(jq -r '.selectedModules' "$CONFIG_FILE")
jvms=$(jq -r '.jvms' "$CONFIG_FILE")
checkoutRoots=$(jq -r '.checkoutRoots' "$CONFIG_FILE")
envVars=$(jq -r '.envVars' "$CONFIG_FILE")
tenants=$(jq -r '.tenants' "$CONFIG_FILE")
users=$(jq -r '.users' "$CONFIG_FILE")
moduleConfigs=$(jq -r '.moduleConfigs' "$CONFIG_FILE")


if [[ "$basicModules" == "null" || "$selectedModules" == "null" || "$jvms" == "null" || "$checkoutRoots" == "null" 
      || "$envVars" == "null" || "$tenants" == "null" || "$users" == "null" || "$moduleConfigs" == "null" ]]; then 
  printf "\n! Could not validate [%s] because one or more basic configuration elements are missing.\n" "$CONFIG_FILE"
  exit
fi  

for name in mod-permissions mod-users mod-login mod-password-validator mod-authtoken mod-configuration mod-users-bl ; do
  found=$(jq --arg name "$name" -r ' .basicModules | any(.name == $name) ' "$CONFIG_FILE")
  if [[ "$found"  != "true" ]]; then
    Errors=("${Errors[@]}" "Basic module $name is missing. Users and authentication will not work without it")
  fi
done

###
echo "* Checking that configurations exist for all basic modules and optional (selected) modules"
selectedModules=$(jq -r '(.basicModules, .selectedModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $selectedModules; do
  found=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -z "$found" ]]
    then
      Errors=("${Errors[@]}" "No configuration found for selected module: $mod")
  fi
done

###
echo "* Checking that the JVMs that are requested by modules are also defined in the configuration and exist on the file system"
requestedJvms=$(jq -r '.moduleConfigs | unique_by(.deployment.jvm)[].deployment.jvm' "$CONFIG_FILE")
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm "$jvm" -r '.jvms | any(.symbol == $jvm)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      Errors=("${Errors[@]}" "JVM $jvm is requested by a module but is not defined in 'jvms'")
    else   
     javaHome=$(jq --arg jvm "$jvm" -r '.jvms[] | select(.symbol == $jvm).home | sub("~";env.HOME)' "$CONFIG_FILE")
     if [ ! -d "$javaHome" ]; then
       Errors=("${Errors[@]}" "Specified path to Java [$javaHome] not found on this file system")
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
      Errors=("${Errors[@]}" "Checkout directory $dir is requested by a module but is not defined in 'checkoutRoots'")
    else 
      directory=$(jq --arg dir "$dir" -r '.checkoutRoots[] | select(.symbol == $dir).directory | sub("~";env.HOME)' "$CONFIG_FILE")
      if [ ! -d "$directory" ]; then
        Errors=("${Errors[@]}" "Specified check-out directory [$directory] not found on this file system")
      fi
    fi
  fi
done

###
echo "* Checking that basic and selected modules are checked out and built"
modules=$(jq -r ' (.selectedModules, .basicModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $modules ; do
  found=$(jq --arg mod $mod -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -n "$found" ]]; then
    checkedOutToSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).checkedOutTo' "$CONFIG_FILE")
    methodSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.method' "$CONFIG_FILE")
    if [[ "$checkedOutToSymbol" == "null" || "$methodSymbol" == "null"  ]]; then
      if [[ "$checkedOutToSymbol" == "null" ]]; then
        Errors=("${Errors[@]}" "Missing configuration for $mod: 'checkedOutTo'.")
      fi
      if [[ "$methodSymbol" == "null" ]]; then
        Errors=("${Errors[@]}" "Missing configuration for $mod: 'deployment.method'.")
      fi
    else 
      checkedOutTo=$(jq --arg symbol "$checkedOutToSymbol" -r '.checkoutRoots[] | select(.symbol == $symbol).directory | sub("~";env.HOME)' "$CONFIG_FILE")
      if [[ ! -d "$checkedOutTo/$mod" ]]; then
        Errors=("${Errors[@]}" "No check-out of $mod found at $checkedOutTo/$mod")
      fi
      if [[ "$methodSymbol" == "DD" ]]; then
        pathToJar=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.pathToJar' "$CONFIG_FILE")
        jvm=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.jvm' "$CONFIG_FILE")
        env=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.env' "$CONFIG_FILE")
        if [ "$pathToJar" == "null" ]; then
          Errors=("${Errors[@]}" "Missing configuration for $mod: 'deployment.pathToJar'.")
        fi      
        if [ "$jvm" == "null" ]; then
          Errors=("${Errors[@]}" "Missing configuration for $mod: 'deployment.jvm'.")
        fi 
        if [ "$env" == "null" ]; then
          Errors=("${Errors[@]}" "Missing configuration for $mod: 'deployment.env'.")
        fi 
        if [[ -d "$checkedOutTo/$mod" && "$pathToJar" != "null" ]]; then
          if [ ! -d "$checkedOutTo/$mod" ]; then
            Errors=("${Errors[@]}" "Module directory [$checkedOutTo/$mod] not found.")
          elif [ ! -d "$checkedOutTo/$mod/target" ]; then
            Errors=("${Errors[@]}" "$mod's checkout directory found but the module doesn't seem to be built. No /target at [$checkedOutTo/$mod/target]")
          elif [ ! -f "$checkedOutTo/$mod/$pathToJar" ]; then
            Errors=("${Errors[@]}" "$mod's checkout directory with subdir /target found but cannot find the requested jar file [$checkedOutTo/$mod/$pathToJar]")
          elif [ ! -f "$checkedOutTo/$mod/target/ModuleDescriptor.json" ]; then
            Errors=("${Errors[@]}" "Found module directory and jar file but cannot find a module descriptor at  $checkedOutTo/$mod/target/ModuleDescriptor.json")
          fi
        fi
      fi
      specifiedVersion=$(jq --arg name "$mod" -r '(.basicModules, .selectedModules)[] | select(.name == $name) | .version ' "$CONFIG_FILE")
      if [[ -f "$checkedOutTo/$mod/target/ModuleDescriptor.json"  ]]; then
        installedVersion=$(jq -r '.id' "$checkedOutTo/$mod/target/ModuleDescriptor.json")
        printf "\n  - %-40s" "$installedVersion"
        if [[ "$specifiedVersion" != "null" && "$installedVersion" != "$mod-$specifiedVersion" ]]; then
          printf " (config declared: %s-%s)"  "$mod"  "$specifiedVersion" 
        fi
      fi  
    fi
    permissions=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).permissions' "$CONFIG_FILE")
    if [[ "$permissions" == "null" ]]; then
      Errors=("${Errors[@]}" "Missing configuration for $mod: 'permissions'.")
    fi
  fi
done

### Check for provisions of required interfaces (on ID level, not version level)
Provided=()
Required=()
unmet=""
for mod in $modules ; do
  if [ -f "$checkedOutTo/$mod/target/ModuleDescriptor.json" ]; then
      required=$(jq -r '. | if has("requires") then .requires[] | .id + " " else "" end' "$checkedOutTo/$mod/target/ModuleDescriptor.json")
      provided=$(jq -r '. | if has("provides") then .provides[] | .id + " " else "" end' "$checkedOutTo/$mod/target/ModuleDescriptor.json")
      for req in $required ; do
        Required=("${Required[@]}" "$req")
      done
      for prov in $provided ; do
        Provided=("${Provided[@]}" "$prov")
      done
  fi
done
faked=$(jq -r '. | if has("fakeApis") then .fakeApis.provides[] | .id + "" else "" end' "$CONFIG_FILE")
for api in $faked; do
  Provided=("${Provided[@]}" "$api") 
done  
for i in "${Required[@]}"; do
  met=false
  for j in "${Provided[@]}"; do
    if [[ "$j" == "$i" ]]; then
       met=true
    fi    
  done
  if ! $met; then
     unmet="$unmet $i "    
  fi   
done
if (( ${#unmet} > 0 )); then
  Errors=("${Errors[@]}" "There are unmet interface dependencies:  $unmet")
fi


### Report results
if (( ${#faked} > 0 )); then
  printf "\n\nThe installation is faking these interfaces: "
  for api in $faked; do
    printf "%s " "$api"
  done 
fi
if [ "${#Errors[@]}" == "0" ]; then
  printf "\n\nConfiguration [%s] looks good!\n\n" "$CONFIG_FILE"
else 
  printf "\n\nValidation failed: %s\n\n" 
  for i in "${Errors[@]}"; do
    printf "  * %s\n" "$i"
  done
fi  
