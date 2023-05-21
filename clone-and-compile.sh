workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  printf "Please provide JSON config file that lists and configures modules to be installed, like:  ./clone-and-compile.sh projects/my-folio.json"
  exit
fi
started=$(date)

function gitStatus() {
  modulePath=$1
  gitStatus=$(git -C "$modulePath" status | head -1)  
  if [[ "$gitStatus" == "On branch master" ]]; then
    echo ""
  else 
    echo " ($gitStatus)"
  fi
}

# Import jq functions for retrieving settings from the config file
source "$workdir/lib/ConfigReader.sh"
printf "\nGit clone and Maven install of selected modules"
printf "\n***********************************************\n"
# Checking file system status for all requested modules
moduleNames=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CONFIG_FILE")
clone=""
compile=""
skip=""
printf "\nChecking file system status of selected modules\n"
for moduleName in $moduleNames ; do
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  modulePath="$baseDir/$moduleName"
  if [ -d "$baseDir" ]; then
    if [ -d "$modulePath" ]; then
      gitStatus=$(gitStatus "$modulePath")
      if [ -f "$modulePath/target/ModuleDescriptor.json" ]; then
        gitStatus=${gitStatus/#"On branch master"/""}
        printf " - %-50s Build found: %s/target/ModuleDescriptor.json\n" "$moduleName$gitStatus" "$modulePath"  
        skip="$skip $moduleName"
      else
        printf " - %-50s Detected no build in %s\n" "$moduleName $gitStatus" "$modulePath"
        compile="$compile $moduleName$gitStatus"  
      fi
    else
      printf " - %-50s Module check-out not found in %s\n" "$moduleName" "$baseDir"
      clone="$clone $moduleName"
      compile="$compile $moduleName"
    fi
  else 
    printf "Cannot check out %s to %s. Directory does not exist.\n" "$moduleName" "$baseDir"
  fi
done
if [[ -z "$cloneAndCompile" && -z "$compile" ]]; then
  printf "\nAll selected modules already checked out and compiled."
else
  printf "\nWill clone:   %s\n" "${clone:-" NONE"}"
  printf "Will compile: %s\n" "${compile:-" NONE"}"
  printf "Skipping:     %s\n" "${skip:-" NONE"}"
  printf "\nUsing check-out directories "
  dirSymbols=$(jq -r '.moduleConfigs | unique_by(.checkedOutTo)[].checkedOutTo' "$CONFIG_FILE")
  for dirSymbol in $dirSymbols ; do
    printf "%s:%s " "$dirSymbol" "$(checkoutRoot "$dirSymbol" "$CONFIG_FILE")"
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
    gitStatus=$(gitStatus $modulePath)
    if [ ! -f "$modulePath/target/ModuleDescriptor.json" ]; then
      printf "$(date) Compiling %s in %s" "$moduleName$gitStatus" "$modulePath"
      javaHome=$(javaHome "$moduleName" "$CONFIG_FILE")
      javaHome=${javaHome#null/""}
      javaHome=${javaHome/#~/$HOME}
      method=$(deploymentMethod "$moduleName" "$CONFIG_FILE")
      printf ", using JAVA_HOME: %s\n" "$javaHome"
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
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$baseDir"   
  fi  
done

printf "\nStarted   %s" "$started"
printf "\nFinished  %s\n" "$(date)"