workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

projectFile=$1
if [[ -z "$projectFile" ]]; then
  printf "\n  Usage:  ./clone-and-compile-project.sh projects/my-folio.json\n\n"
  printf "  The script will 'git clone' modules that are not present in the specified directories\n"
  printf "  and 'mvn install' and optionally 'docker build' those that have no target directory.\n\n"
  exit
fi
if [[ ! -f "$projectFile" ]]; then
  printf "\n  Could not find project file [%s] to clone and compile modules from.\n\n" "$projectFile"
  exit
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source "$workdir/lib/ConfigReader.sh"
source "$workdir/lib/Utils.sh"

mainSourceDirectory=$(sourceDirectory "$projectFile")
if [[ -z "$mainSourceDirectory" ]]; then
  printf "\n !! Project configuration has no main source directory ('sourceDirectory' not set), cannot continue.\n\n"
  exit
elif [[ ! -d "$mainSourceDirectory" ]]; then
  printf "\n !! The projects main source directory for module check-outs does not exist. Please create '%s' to run with this configuration.\n\n" "$mainSourceDirectory"
  exit
fi

printf "\nGit clone and Maven install of selected modules"
printf "\n***********************************************\n"
# Checking file system status for all requested modules
moduleNames=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$projectFile")
clone=""
compile=""
skip=""
printf "\nChecking file system status of selected modules\n"
for moduleName in $moduleNames ; do
  sourceDirectory=$(moduleDirectory "$moduleName" "$projectFile")
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
  printf "\nUsing main source directory: %s" "$mainSourceDirectory"
  sourceDirectories=$(jq -r '(.basicModules,.selectedModules) | unique_by(.sourceDirectory)[].sourceDirectory' "$projectFile")
  for symbol in $sourceDirectories ; do
    if [[ "$symbol" != "null" ]]; then
      printf " Alternative directory: %s:%s " "$symbol" "$(alternativeDirectory "$symbol" "$projectFile")"
    fi
  done
fi 
printf "\n\n"
while true
do
    read -r -p 'Continue [y/N]? ' choice
    choice=${choice:-N}
    case "$choice" in
      y|Y) break;;
      *) exit;;
    esac
done

for moduleName in $moduleNames ; do
  sourceDirectory=$(moduleDirectory "$moduleName" "$projectFile")
  modulePath="$sourceDirectory/$moduleName"
  gitHost=$(moduleRepoOrDefault "$moduleName" "$projectFile")
  if [ -d "$sourceDirectory" ]; then
    if [ ! -d "$modulePath" ]; then
      printf "\n$(date) Cloning %s to %s from %s/%s\n" "$moduleName" "$sourceDirectory" "$gitHost" "$moduleName"
      git clone -q --recurse-submodules "$gitHost/$moduleName"  "$modulePath"
    fi
    if [ ! -f "$modulePath/target/ModuleDescriptor.json" ]; then
      ./mod-compile.sh "$moduleName" "$projectFile"
    fi
  else
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$sourceDirectory"
  fi  
done

printf "\nStarted   %s" "$started"
printf "\nFinished  %s\n" "$(date)"