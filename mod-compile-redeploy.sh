moduleName="$1"
projectFile="$2"

./mod-compile.sh "$moduleName" "$projectFile"
./mod-compile-redeploy.sh "$moduleName" "$projectFile"
  