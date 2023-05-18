workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  printf "Please provide JSON config file that lists and configures modules to be installed, like:  ./clone-and-compile.sh projects/my-folio.json"
  exit
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source "$workdir/configutils/jsonConfigReader.sh"

moduleNames=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CONFIG_FILE")
clone=""
compile=""
skip=""
for moduleName in $moduleNames ; do
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  modulePath="$baseDir/$moduleName"
  if [ -d "$baseDir" ]; then
    if [ -d "$modulePath" ]; then
      if [ -f "$modulePath/target/ModuleDescriptor.json" ]; then
        skip="$skip $moduleName"
      else 
        compile="$compile $moduleName"  
      fi
    else 
      clone="$clone $moduleName"
      compile="$compile $moduleName"
    fi
  else 
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$baseDir"   
  fi
done
if [[ -z "$cloneAndCompile" && -z "$compile" ]]; then
  printf "All modules already cloned and compiled: %s" "$skip"
else
  printf "Will clone %s\n" "${clone:-"no modules"}"
  printf "Will compile %s\n" "${compile:-"no modules"}"
  printf "Skipping %s\n" "${skip:-none}"
  printf "\nCheck-out directories:\n" 
  dirSymbols=$(jq -r '.moduleConfigs | unique_by(.checkedOutTo)[].checkedOutTo' "$CONFIG_FILE")
  for dirSymbol in $dirSymbols ; do
    printf "%s:%s\n" "$dirSymbol" "$(checkoutRoot "$dirSymbol" "$CONFIG_FILE")"
  done
fi 
printf "\n\n"
while true
do
    read -r -p 'Continue [y/N]? ' choice
    choice=${choice:-N}
    case "$choice" in
      n|N) exit;;
      y|Y) break;;
      *) exit;;
    esac
done

for moduleName in $moduleNames ; do
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  modulePath="$baseDir/$moduleName"
  gitHost=$(moduleConfig "$moduleName" "$CONFIG_FILE" | jq -r '.gitHost')
  gitHost=${gitHost/#null/"https://github.com/folio-org"}
  if [ -d "$baseDir" ]; then
    if [ ! -d "$modulePath" ]; then
      printf "\n$(date) Cloning %s to %s from %s/%s\n" "$moduleName" "$baseDir" "$gitHost" "$moduleName"
      git clone -q --recurse-submodules "$gitHost/$moduleName"  "$modulePath"
    fi
    if [ ! -f "$modulePath/target/ModuleDescriptor.json" ]; then
      printf "$(date) Compiling %s in %s\n" "$moduleName" "$modulePath"
      javaHome=$(javaHome "$moduleName" "$CONFIG_FILE")
      javaHome=${javaHome#null/""}
      javaHome=${javaHome/#~/$HOME}
      printf "Using JAVA_HOME: %s\n" "$javaHome"
      dir=$(pwd)
      cd "$modulePath" || return
      export JAVA_HOME="$javaHome" ; mvn -q clean install -D skipTests
      cd "$dir" || return
    fi
  else 
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$baseDir"   
  fi  
done

printf "\nStarted %s. Finished %s\n" "$started" "$(date)"