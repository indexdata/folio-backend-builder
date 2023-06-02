SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
moduleName=$1
projectFile=$2
source "$workdir/lib/ConfigReader.sh"

function filesAge() {
  days="$((($(date +%s) - $(date +%s -r "$jarFile")) / 86400))"
  hours="$((($(date +%s) - $(date +%s -r "$jarFile")) / 3600))"
  minutes="$((($(date +%s) - $(date +%s -r "$jarFile")) / 60))"
  if [[ $days -eq 0 ]]; then
    if [[ $hours -gt 1 ]]; then
      printf "\n\n  Last compiled %s hours ago." $hours
    else
      printf "   (Compiled %s minutes ago)" $minutes
    fi
  else
    printf "\n\n    ** This jar was last compiled %s days ago ** " $days
  fi
}

dd=$(makeDeploymentDescriptor "$moduleName" "$projectFile")
id=$(moduleDescriptorId "$moduleName" "$projectFile")
curl -X DELETE "http://localhost:9130/_/discovery/modules/$id"
curl -w '\n' -D - -s -H "Content-type: application/json" -d "$dd" http://localhost:9130/_/discovery/modules

jarFile=$(moduleDirectory "$moduleName" "$projectFile")/$moduleName/$(pathToJar "$moduleName" "$projectFile")
printf "\n\nRedeployment of %s. %s\n\n" "$jarFile"  "$(filesAge "$jarFile")"
