here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
moduleName=$1
projectFile=$2
source "$here/lib/ConfigReader.sh"
source "$here/lib/Utils.sh"

sourceDirectory=$(moduleDirectory "$moduleName" "$projectFile")
modulePath="$sourceDirectory/$moduleName"

gitStatus=$(gitStatus "$modulePath")
javaHome=$(javaHome "$moduleName" "$projectFile")
javaHome=${javaHome#null/""}
javaHome=${javaHome/#~/$HOME}
method=$(deploymentMethod "$moduleName" "$projectFile")

printf "$(date) Compiling %s in %s with JVM [%s]\n" "$moduleName$gitStatus" "$modulePath" "$javaHome"
dir=$(pwd)
cd "$modulePath" || return
export JAVA_HOME="$javaHome" ; mvn -q clean install -D skipTests

if [[ "$method" == "DOCKER" ]]; then
  dockerImage=$(jq -r '.launchDescriptor.dockerImage' "$modulePath/target/ModuleDescriptor.json")
  printf "Building docker image %s\n" "$dockerImage"
  docker build -q -t "$dockerImage" .
fi
cd "$dir" || return
