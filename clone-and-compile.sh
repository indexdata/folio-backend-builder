workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CONFIG_FILE=$1
if [[ -z "$CONFIG_FILE" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./clone-modules.sh projects/my-folio.json"
  exit
fi
started=$(date)

# Import jq functions for retrieving settings from the config file
source "$workdir/configutils/jsonConfigReader.sh"

moduleNames=$(jq -r '(.basicModules, .selectedModules)[] | .name ' "$CONFIG_FILE")
for moduleName in $moduleNames ; do
  baseDir=$(baseDir "$moduleName" "$CONFIG_FILE")
  modulePath="$baseDir/$moduleName"
  gitHost=$(moduleConfig "$moduleName" "$CONFIG_FILE" | jq -r '.githost')
  if [ -d "$baseDir" ]; then
    if [ -d "$modulePath" ]; then
        echo "$modulePath already exists, not cloning $moduleName"
    else   
        echo "Cloning $moduleName to $baseDir from $gitHost/$moduleName"
        git clone --recurse-submodules "$gitHost/$moduleName"  "$modulePath"
    fi
    cd $modulePath
    mvn clean install -D skipTests
    cd $workdir
  else 
    printf "Cannot clone %s to %s. Directory does not exist.\n" "$moduleName" "$baseDir"   
  fi  
done
printf "\nFinished\n"   