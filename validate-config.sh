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
function gitStatus() {
  modulePath=$1
  gitStatus=$(git -C "$modulePath" status | head -1)  
  if [[ "$gitStatus" == "On branch master" ]]; then
    echo ""
  else 
    echo " [$gitStatus]"
  fi
}


printf "* Checking that the major, required sections are present in the JSON config\n"
basicModules=$(jq -r '.basicModules' "$CONFIG_FILE")
selectedModules=$(jq -r '.selectedModules' "$CONFIG_FILE")
jvms=$(jq -r '.jvms' "$CONFIG_FILE")
sourceDirectories=$(jq -r '.sourceDirectories' "$CONFIG_FILE")
envVars=$(jq -r '.envVars' "$CONFIG_FILE")
tenants=$(jq -r '.tenants' "$CONFIG_FILE")
users=$(jq -r '.users' "$CONFIG_FILE")
moduleConfigs=$(jq -r '.moduleConfigs' "$CONFIG_FILE")
if [[ "$basicModules" == "null" || "$selectedModules" == "null" || "$jvms" == "null" || "$sourceDirectories" == "null" 
      || "$envVars" == "null" || "$tenants" == "null" || "$users" == "null" || "$moduleConfigs" == "null" ]]; then 
  printf "\n! Could not validate [%s] because one or more basic configuration elements are missing.\n" "$CONFIG_FILE"
  exit
fi  

printf "* Checking that the seven basic user infrastructure modules are selected\n"
for name in mod-permissions mod-users mod-login mod-password-validator mod-authtoken mod-configuration mod-users-bl ; do
  found=$(jq --arg name "$name" -r ' .basicModules | any(.name == $name) ' "$CONFIG_FILE")
  if [[ "$found"  != "true" ]]; then
    Errors=("${Errors[@]}" "Basic module $name is missing. Users and authentication will not work without it")
  fi
done

printf "* Checking that configurations exist for all basic modules and all selected modules\n"
allModules=$(jq -r '(.basicModules, .selectedModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $allModules; do
  found=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -z "$found" ]]
    then
      Errors=("${Errors[@]}" "No configuration found for selected module: $mod")
  fi
done

printf "* Checking that the JVMs that are requested by modules are also defined in the configuration and exist on the file system\n"
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

printf "* Checking that Git checkout directories that are referenced by modules are also defined in the configuration and exist on the file system\n"
allModules=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CONFIG_FILE")
requestedCheckoutDirs=$(jq -r '(.basicModules,.selectedModules) | unique_by(.source)[].source' "$CONFIG_FILE")
for dir in $requestedCheckoutDirs; do
  if [[ "$dir" != "null" ]]; then
    found=$(jq --arg dir "$dir" -r '.sourceDirectories | any(.symbol == $dir)' "$CONFIG_FILE")
    if [[ "$found" != "true" ]]; then 
      Errors=("${Errors[@]}" "Checkout directory $dir is requested by a module but is not defined in 'sourceDirectories'")
    else 
      directory=$(jq --arg dir "$dir" -r '.sourceDirectories[] | select(.symbol == $dir).directory | sub("~";env.HOME)' "$CONFIG_FILE")
      if [ ! -d "$directory" ]; then
        Errors=("${Errors[@]}" "Specified check-out directory [$directory] not found on this file system")
      fi
    fi
  fi
done

printf "* Checking that basic and selected modules are checked out and built\n"
modules=$(jq -r ' (.selectedModules, .basicModules)[] | select(.name != null) | .name ' "$CONFIG_FILE")
for mod in $modules ; do
  found=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod)' "$CONFIG_FILE")
  if [[ -n "$found" ]]; then
    sourceDirectorySymbol=$(jq --arg mod "$mod" -r '(.selectedModules,.basicModules)[] | select(.name == $mod).source' "$CONFIG_FILE")
    methodSymbol=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).deployment.method' "$CONFIG_FILE")
    if [[ "$sourceDirectorySymbol" == "null" || "$methodSymbol" == "null"  ]]; then
      if [[ "$sourceDirectorySymbol" == "null" ]]; then
        Errors=("${Errors[@]}" "Missing configuration for $mod: 'source'.")
      fi
      if [[ "$methodSymbol" == "null" ]]; then
        Errors=("${Errors[@]}" "Missing configuration for $mod: 'deployment.method'.")
      fi
    else
      sourceDirectory=$(jq --arg symbol "$sourceDirectorySymbol" -r '.sourceDirectories[] | select(.symbol == $symbol).directory | sub("~";env.HOME)' "$CONFIG_FILE")
      if [[ ! -d "$sourceDirectory/$mod" ]]; then
        Errors=("${Errors[@]}" "No check-out of $mod found at $sourceDirectory/$mod")
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
        if [[ -d "$sourceDirectory/$mod" && "$pathToJar" != "null" ]]; then
          if [[ ! -d "$sourceDirectory/$mod" ]]; then
            Errors=("${Errors[@]}" "Module directory [$sourceDirectory/$mod] not found.")
            printf "%s/%s not found" "$sourceDirectory" "$mod"
          elif [[ ! -d "$sourceDirectory/$mod/target" ]]; then
            Errors=("${Errors[@]}" "$mod's checkout directory found but the module doesn't seem to be built. No /target in [$sourceDirectory/$mod]")
            printf "\n  Can't find build for '%s'. No /target directory in %s/%s" "$mod" "$sourceDirectory" "$mod"
          elif [[ ! -f "$sourceDirectory/$mod/$pathToJar" ]]; then
            Errors=("${Errors[@]}" "$mod's checkout directory with subdir /target found but cannot find the requested jar file [$sourceDirectory/$mod/$pathToJar]")
          elif [[ ! -f "$sourceDirectory/$mod/target/ModuleDescriptor.json" ]]; then
            Errors=("${Errors[@]}" "Found module directory and jar file but cannot find a module descriptor at  $sourceDirectory/$mod/target/ModuleDescriptor.json")
          fi
        fi
      fi
      specifiedVersion=$(jq --arg name "$mod" -r '(.basicModules, .selectedModules)[] | select(.name == $name) | .version ' "$CONFIG_FILE")
      if [[ -f "$sourceDirectory/$mod/target/ModuleDescriptor.json"  ]]; then
        installedVersion=$(jq -r '.id' "$sourceDirectory/$mod/target/ModuleDescriptor.json")
        gitStatus=$(gitStatus "$sourceDirectory/$mod")
        gitStatus=${gitStatus/#"On branch master"/""}
        printf "\n  - %-40s%-30s" "$installedVersion" "$gitStatus"
        if [[ "$specifiedVersion" != "null" && "$installedVersion" != "$mod-$specifiedVersion" ]]; then
          printf " (config said: %s-%s)"  "$mod"  "$specifiedVersion" 
        fi
      fi  
    fi
    permissions=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod).permissions' "$CONFIG_FILE")
    if [[ "$permissions" == "null" ]]; then
      Errors=("${Errors[@]}" "Missing configuration for $mod: 'permissions'.")
    fi
  fi
done

printf "\n\n* Checking that all interfaces that are required are also provided (or faked). Checking interface id level only, not for required versions\n"
Provided=()
Required=()
unmet=""
modules=$(jq -r ' (.selectedModules, .basicModules)[] | .name ' "$CONFIG_FILE")
for mod in $modules ; do 
  sourceDirectorySymbol=$(jq --arg mod "$mod" -r '(.selectedModules,.basicModules)[] | select(.name == $mod).source' "$CONFIG_FILE")
  sourceDirectory=$(jq --arg symbol "$sourceDirectorySymbol" -r '.sourceDirectories[] | select(.symbol == $symbol).directory | sub("~";env.HOME)' "$CONFIG_FILE")
  if [ -f "$sourceDirectory/$mod/target/ModuleDescriptor.json" ]; then
      required=$(jq -r '. | if has("requires") then .requires[] | .id + " " else "" end' "$sourceDirectory/$mod/target/ModuleDescriptor.json")
      provided=$(jq -r '. | if has("provides") then .provides[] | .id + " " else "" end' "$sourceDirectory/$mod/target/ModuleDescriptor.json")
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
  printf "\nThe installation has fakes for these interfaces: "
  for api in $faked; do
    printf "%s " "$api"
  done 
fi
if [ "${#Errors[@]}" == "0" ]; then
  printf "\n\nConfiguration [%s] looks good!\n\n" "$CONFIG_FILE"
else 
  printf "\n\nValidation failed:\n\n"
  for i in "${Errors[@]}"; do
    printf "  * %s\n" "$i"
  done
fi  
