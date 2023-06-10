SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
moduleName=$1
projectFile=$2
source "$workdir/lib/ConfigReader.sh"
source "$workdir/lib/Utils.sh"

function reportCompilationsAge() {
  age="$(filesAge "$jarFile")"
  case $age in
     *seconds) printf " (compiled %s ago)" "$age" ;;   
     *minutes) printf " (compiled %s ago)" "$age" ;;
     *hours)   printf "       ! Compiled %s ago." "$age" ;;
     *days)    printf "\n\n   ** This jar file was last compiled %s ago ** \n\n" "$age" ;;
     *)        printf "jar file's age %s " "$age" ;;
  esac
}

dd=$(makeDeploymentDescriptor "$moduleName" "$projectFile")
id=$(moduleDescriptorId "$moduleName" "$projectFile")
curl -X DELETE "http://localhost:9130/_/discovery/modules/$id"
curl -w '\n' -D - -s -H "Content-type: application/json" -d "$dd" http://localhost:9130/_/discovery/modules

jarFile=$(moduleDirectory "$moduleName" "$projectFile")/$moduleName/$(pathToJar "$moduleName" "$projectFile")
printf "\n\nRedeployment of %s. %s\n\n" "$jarFile"  "$(reportCompilationsAge "$jarFile")"
