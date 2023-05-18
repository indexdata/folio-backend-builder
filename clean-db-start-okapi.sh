SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1

if [ -d "$pathToOkapi/okapi/okapi-core/target" ]; then
  "$SCRIPT_DIR"/postgresdb/drop-pgdb-okapi_modules-and-roles.sh
  "$SCRIPT_DIR"/postgresdb/create-pgdb-okapi_modules.sh
  "$SCRIPT_DIR"/okapi/init-db-start-okapi.sh "$pathToOkapi" 
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target\n" "$pathToOkapi"
fi