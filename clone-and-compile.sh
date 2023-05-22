workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  printf "Please provide JSON config file that lists and configures modules to be installed, like:  ./clone-and-compile.sh projects/my-folio.json"
  exit
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source "$workdir/lib/ConfigReader.sh"
source "$workdir/lib/Utils.sh"

printf "\nGit clone and Maven install of selected modules"
printf "\n***********************************************\n"
# Checking file system status for all requested modules
moduleNames=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CONFIG_FILE")
clone=""
compile=""
skip=""
printf "\nChecking file system status of selected modules\n"
for moduleName in $moduleNames ; do
  sourceDirectory=$(moduleDirectory "$moduleName" "$CONFIG_FILE")
  modulePath="$sourceDirectory/$moduleName"
  if [ -d "$sourceDirectory" ]; then
    if [ -d "$modulePath" ]; then
      gitStatus=$(gitStatus "$modulePath")
      if [ -f "$modulePath/target/ModuleDescriptor.json" ]; then
        printf " - %-25s%-35s Got %s/target\n" "$moduleName" "$gitStatus" "$modulePath"
        skip="$skip $moduleName"
      else
        printf " - %-60s - Detected no build in %s\n" "$moduleName $gitStatus" "$modulePath"
        compile="$compile $moduleName$gitStatus"  
      fi
    else
      printf " - %-60s - Module check-out not found in %s\n" "$moduleName" "$sourceDirectory"
      clone="$clone $moduleName"
      compile="$compile $moduleName"
    fi
  else 
    printf "Cannot check out %s to %s. Directory does not exist.\n" "$moduleName" "$sourceDirectory"
  fi
done
if [[ -z "$cloneAndCompile" && -z "$compile" ]]; then
  printf "\nAll selected modules already checked out and compiled."
else
  printf "\nWill clone:   %s\n" "${clone:-" NONE"}"
  printf "Will compile: %s\n" "${compile:-" NONE"}"
  printf "Skipping:     %s\n" "${skip:-" NONE"}"
  printf "\nUsing source directories "
  sourceDirectories=$(jq -r '(.basicModules,.selectedModules) | unique_by(.sourceDirectory)[].sourceDirectory' "$CONFIG_FILE")
  for symbol in $sourceDirectories ; do
    printf "%s:%s " "$symbol" "$(alternativeDirectory "$symbol" "$CONFIG_FILE")"
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
  sourceDirectory=$(moduleDirectory "$moduleName" "$CONFIG_FILE")
  modulePath="$sourceDirectory/$moduleName"
  gitHost=$(moduleRepo "$moduleName" "$CONFIG_FILE")
  if [ -d "$sourceDirectory" ]; then
    if [ ! -d "$modulePath" ]; then
      printf "\n$(date) Cloning %s to %s from %s/%s\n" "$moduleName" "$sourceDirectory" "$gitHost" "$moduleName"
      git clone -q --recurse-submodules "$gitHost/$moduleName"  "$modulePath"
    fi
    gitStatus=$(gitStatus "$modulePath")
    if [ ! -f "$modulePath/target/ModuleDescriptor.json" ]; then
      printf "$(date) Compiling %s in %s" "$moduleName$gitStatus" "$modulePath"
      javaHome=$(javaHome "$moduleName" "$CONFIG_FILE")
      javaHome=${javaHome#null/""}
      javaHome=${javaHome/#~/$HOME}
      method=$(deploymentMethod "$moduleName" "$CONFIG_FILE")
      printf " with JVM [%s]\n" "$javaHome"
      dir=$(pwd)
      cd "$modulePath" || return
      export JAVA_HOME="$javaHome" ; mvn -q clean install -D skipTests
      if [[ "$method" == "DOCKER" ]]; then
        dockerImage=$(jq -r '.launchDescriptor.dockerImage' "$modulePath/target/ModuleDescriptor.json")
        printf "Building docker image %s\n" "$dockerImage"
        docker build -q -t "$dockerImage" .
      fi
      cd "$dir" || return
    fi
  else 
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$sourceDirectory"
  fi  
done

printf "\nStarted   %s" "$started"
printf "\nFinished  %s\n" "$(date)"