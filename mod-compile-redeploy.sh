here=${0%/*}
moduleName="$1"
projectFile="$2"

"$here"/mod-compile.sh "$moduleName" "$projectFile"
"$here"/mod-redeploy.sh "$moduleName" "$projectFile"
  