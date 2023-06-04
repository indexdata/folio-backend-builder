moduleName="$1"
projectFile="$2"

./compile-module.sh "$moduleName" "$projectFile"
./redeploy-module.sh "$moduleName" "$projectFile"
  