# For a FOLIO configuration, builds list of all provided interfaces with module id and API paths.
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

oneDirUp=$(echo "$workdir" | rev | cut -d'/' -f2- | rev)
source "$oneDirUp"/lib/ConfigReader.sh
source "$oneDirUp"/lib/Utils.sh

# All interfaces provided by all (cloned and compiled) modules listed in a project configuration (except underscore interfaces like _tenant)
function providedInterfaces() {
  modules=$(jq -r ' (.selectedModules, .basicModules)[] | .name ' "$1")
  directories=""
  # find all module descriptors
  for moduleName in $modules ; do
    directories="$directories  $(moduleDirectory "$moduleName" "$CF")/$moduleName/target/ModuleDescriptor.json"
  done
  # shellcheck disable=SC2086
  jq -n  '[ inputs | .id as $moduleId |
           .provides[] | select( (.id | startswith("_")) == false) |
              { id, "module": $moduleId, "paths": [.handlers[].pathPattern] | unique } ]' $directories
}

function requiredInterfaces() {
  modules=$(jq -r ' (.selectedModules, .basicModules)[] | .name ' "$1")
  directories=""
  # find all module descriptors
  for moduleName in $modules ; do
    directories="$directories  $(moduleDirectory "$moduleName" "$CF")/$moduleName/target/ModuleDescriptor.json"
  done
  # shellcheck disable=SC2086
  jq -n  '[ inputs | .id as $moduleId | .requires[]? | { id, "module": $moduleId }]' $directories
}

# Find interface that services a given API path
function providedByPath() {
  providedInterfaces "$2" | jq --arg path "$1" -r  '. | map(select(.paths[] | contains ($path))) | unique '
}

# Find interfaces serviced by a given module (by module name)
function providedByModule() {
  providedInterfaces "$2" | jq --arg mod "$1" -r '[.[] | select(.module | startswith ($mod))]'
}

# Find interface by name (id)
function providedByName() {
  providedInterfaces "$2" | jq --arg name "$1" -r '[.[] | select(.id == $name)]'
}

# Find interfaces serviced by a given module (by module name)
function requiredByModule() {
  requiredInterfaces "$2" | jq --arg mod "$1" -r '[.[] | select(.module | startswith ($mod))]'
}

# Find interface by name (id)
function requiredByName() {
  requiredInterfaces "$2" | jq --arg name "$1" -r '[.[] | select(.id == $name)]'
}