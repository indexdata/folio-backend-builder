CF=$1

if [[ -z "$CF" ]]; then
  printf "\nPlease provide JSON config file to validate:  ./validate-config.sh my-folio.json\n"
  exit
else 
  printf "\nValidating [%s]\n\n" "$CF"
  parsed=$(jq -r '.' "$CF")
  if [[ -z "$parsed" ]]; then
    printf "\n! Could not validate [%s] due to parsing errors.\n" "$CF"
    exit
  fi
fi
Errors=()
function logError() {
  Errors=("${Errors[@]}" "$1")
}
source lib/Utils.sh
source lib/ConfigReader.sh

mainDirectory=$(sourceDirectory "$CF")

if [[ -z "$mainDirectory" ]]; then
  printf "Main (default) source directory not defined\n\n"
else
  printf "Main (default) source directory is [%s]\n\n" "$mainDirectory"
fi


if [[ -z "$mainDirectory" ]]; then
  moduleNames=$(jq -r '(.basicModules,.selectedModules)[] | .name' "$CF")
  for moduleName in $moduleNames ; do
    if [[ -z "$(moduleDirectory "$moduleName" "$CF")" ]]; then
      printf "No default source directory and no explicit source directory defined for %s\n" "$moduleName"
      printf "Need the source directories of all modules for further validation. Exiting.\n\n"
      exit
    fi
  done
fi
printf "* Checking that the major, required sections are present in the JSON config\n"

if [[ "$(basicModules "$CF")" == "null" ||
      "$(selectedModules "$CF")" == "null" ||
      "$(jvms "$CF")" == "null" ||
      "$(envVars "$CF")" == "null" ||
      "$(tenants "$CF")" == "null" ||
      "$(users "$CF")" == "null" ||
      "$(moduleConfigs "$CF")" == "null" ]]; then
  printf "\n! Could not validate [%s] because one or more basic configuration elements are missing.\n" "$CF"
  exit
fi

if [[ -z "$(sourceDirectory "$CF")" && -z "$(alternativeDirectories "$CF")" ]]; then
  printf "\n! Could not validate [%s] because both 'sourceDirectory' and 'alternativeDirectories' are missing. At least one source directory must be defined.\n" "$CF"
  exit
fi

printf "* Checking that the seven basic user infrastructure modules are selected\n"
for name in mod-permissions mod-users mod-login mod-password-validator mod-authtoken mod-configuration mod-users-bl ; do
  found=$(jq --arg name "$name" -r ' .basicModules | any(.name == $name) ' "$CF")
  if [[ "$found"  != "true" ]]; then
    logError"Basic module $name is missing. Users and authentication will not work without it"
  fi
done

printf "* Checking that configurations exist for all basic modules and all selected modules\n"
allModules=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CF")
for mod in $allModules; do
  found=$(jq --arg mod "$mod" -r '.moduleConfigs[] | select(.name == $mod)' "$CF")
  if [[ -z "$found" ]]
    then
      logError"No configuration found for selected module: $mod"
  fi
done

printf "* Checking that the JVMs that are requested by modules are also defined in the configuration and exist on the file system\n"
requestedJvms=$(jq -r '.moduleConfigs | unique_by(.deployment.jvm)[].deployment.jvm' "$CF")
for jvm in $requestedJvms; do
  if [[ ! "$jvm" == "null" ]]; then
    found=$(jq --arg jvm "$jvm" -r '.jvms | any(.symbol == $jvm)' "$CF")
    if [[ "$found" != "true" ]]; then 
      logError "JVM $jvm is requested by a module but is not defined in 'jvms'"
    else   
     javaHome=$(jq --arg jvm "$jvm" -r '.jvms[] | select(.symbol == $jvm).home | sub("~";env.HOME)' "$CF")
     if [ ! -d "$javaHome" ]; then
       logError"Specified path to Java [$javaHome] not found on this file system"
     fi
    fi
  fi
done

allModules=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CF")
requestedCheckoutDirs=$(jq -r '(.basicModules,.selectedModules) | unique_by(.sourceDirectory)[].sourceDirectory' "$CF")
if [[ "$requestedCheckoutDirs" != "null" ]]; then
  printf "* Checking that Git checkout directories that are referenced by modules are also defined in the configuration and exist on the file system\n"
  for dir in $requestedCheckoutDirs; do
    if [[ "$dir" != "null" ]]; then
      found=$(jq --arg dir "$dir" -r '.alternativeDirectories | any(.symbol == $dir)' "$CF")
      if [[ "$found" != "true" ]]; then
        logError "Checkout directory $dir is requested by a module but is not defined in 'alternativeDirectories'"
      else
        directory=$(jq --arg dir "$dir" -r '.alternativeDirectories[] | select(.symbol == $dir).directory | sub("~";env.HOME)' "$CF")
        if [ ! -d "$directory" ]; then
          logError"Specified check-out directory [$directory] not found on this file system"
        fi
      fi
    fi
  done
fi

printf "* Checking that basic and selected modules are checked out and built\n"
modules=$(jq -r ' (.selectedModules, .basicModules)[] | .name ' "$CF")
for moduleName in $modules ; do
  found=$(jq --arg mod "$moduleName" -r '.moduleConfigs[] | select(.name == $mod)' "$CF")
  if [[ -n "$found" ]]; then
    methodSymbol=$(jq --arg mod "$moduleName" -r '.moduleConfigs[] | select(.name == $mod).deployment.method' "$CF")
    if [[ "$methodSymbol" == "null"  ]]; then
        logError "Missing configuration for $mod: 'deployment.method'."
    else
      sourceDirectory="$(moduleDirectory "$moduleName" "$CF")"
      if [[ ! -d "$sourceDirectory/$moduleName" ]]; then
        logError "No check-out of $moduleName found at $sourceDirectory/$moduleName"
      fi
      if [[ "$methodSymbol" == "DD" ]]; then
        pathToJar="$(pathToJar "$moduleName" "$CF")"
        if [ "$pathToJar" == "null" ]; then
          logError "Missing configuration for $moduleName: 'deployment.pathToJar'."
        fi      
        if [ "$(jvm "$moduleName" "$CF")" == "null" ]; then
          logError "Missing configuration for $moduleName: 'deployment.jvm'."
        fi 
        if [ "$(env "$moduleName" "$CF")" == "null" ]; then
          logError "Missing configuration for $moduleName: 'deployment.env'."
        fi 
        if [[ -d "$sourceDirectory/$moduleName" && "$pathToJar" != "null" ]]; then
          if [[ ! -d "$sourceDirectory/$moduleName" ]]; then
            logError "Module directory [$sourceDirectory/$moduleName] not found."
            printf "%s/%s not found" "$sourceDirectory" "$moduleName"
          elif [[ ! -d "$sourceDirectory/$moduleName/target" ]]; then
            logError "$moduleName's checkout directory found but the module doesn't seem to be built. No /target in [$sourceDirectory/$moduleName]"
            printf "\n  Can't find build for '%s'. No /target directory in %s/%s" "$moduleName" "$sourceDirectory" "$moduleName"
          elif [[ ! -f "$sourceDirectory/$moduleName/$pathToJar" ]]; then
            logError "$moduleName's checkout directory with subdir /target found but cannot find the requested jar file [$sourceDirectory/$moduleName/$pathToJar]"
          elif [[ ! -f "$sourceDirectory/$moduleName/target/ModuleDescriptor.json" ]]; then
            logError "Found module directory and jar file but cannot find a module descriptor at  $sourceDirectory/$moduleName/target/ModuleDescriptor.json"
          fi
        fi
      fi
      specifiedVersion=$(jq --arg name "$moduleName" -r '(.basicModules, .selectedModules)[] | select(.name == $name) | .version ' "$CF")
      if [[ -f "$sourceDirectory/$moduleName/target/ModuleDescriptor.json"  ]]; then
        installedVersion=$(jq -r '.id' "$sourceDirectory/$moduleName/target/ModuleDescriptor.json")
        gitStatus=$(gitStatus "$sourceDirectory/$moduleName")
        gitStatus=${gitStatus/#"On branch master"/""}
        printf "\n  %s %-40s%-30s" "$sourceDirectory" "$installedVersion" "$gitStatus"
        if [[ "$specifiedVersion" != "null" && "$installedVersion" != "$moduleName-$specifiedVersion" ]]; then
          printf " (config said: %s-%s)"  "$moduleName"  "$specifiedVersion"
        fi
      fi  
    fi
    permissions=$(jq --arg moduleName "$moduleName" -r '.moduleConfigs[] | select(.name == $moduleName).permissions' "$CF")
    if [[ "$permissions" == "null" ]]; then
      logError "Missing configuration for $moduleName: 'permissions'."
    fi
  fi
done

printf "\n\n* Checking that all interfaces that are required are also provided (or faked). Checking interface id level only, not for required versions\n"
Provided=()
Required=()
unmet=""
modules=$(jq -r ' (.selectedModules, .basicModules)[] | .name ' "$CF")
for moduleName in $modules ; do
  sourceDirectory=$(moduleDirectory "$moduleName" "$CF")
  if [ -f "$sourceDirectory/$moduleName/target/ModuleDescriptor.json" ]; then
      required=$(jq -r '. | if has("requires") then .requires[] | .id + " " else "" end' "$sourceDirectory/$moduleName/target/ModuleDescriptor.json")
      provided=$(jq -r '. | if has("provides") then .provides[] | .id + " " else "" end' "$sourceDirectory/$moduleName/target/ModuleDescriptor.json")
      for req in $required ; do
        Required=("${Required[@]}" "$req")
      done
      for prov in $provided ; do
        Provided=("${Provided[@]}" "$prov")
      done
  fi
done
faked=$(jq -r '. | if has("fakeApis") then .fakeApis.provides[] | .id + "" else "" end' "$CF")
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
  logError "There are unmet interface dependencies:  $unmet"
fi

### Report results
if (( ${#faked} > 0 )); then
  printf "\nThe installation has fakes for these interfaces: "
  for api in $faked; do
    printf "%s " "$api"
  done 
fi
if [ "${#Errors[@]}" == "0" ]; then
  printf "\n\nConfiguration [%s] looks good!\n\n" "$CF"
else 
  printf "\n\nValidation failed:\n\n"
  for i in "${Errors[@]}"; do
    printf "  * %s\n" "$i"
  done
fi  
