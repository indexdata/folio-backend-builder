here=${0%/*}
moduleName=$1
projectFile=$2
source "$here/lib/ConfigReader.sh"
source "$here/lib/Utils.sh"

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
curl -w '\n' -D - -s -H "Content-type: application/json" -d "$dd" http://localhost:9130/_/discovery/modules

jarFile=$(moduleDirectory "$moduleName" "$projectFile")/$moduleName/$(pathToJar "$moduleName" "$projectFile")
printf "\n\nDeployed %s. %s\n\n" "$jarFile"  "$(reportCompilationsAge "$jarFile")"
