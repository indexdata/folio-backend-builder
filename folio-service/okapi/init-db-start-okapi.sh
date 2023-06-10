# Initializes (empties) Okapi's database (tenants and modules)
# Starts Okapi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1

if [ -d "$pathToOkapi/okapi/okapi-core/target" ]; then
  "$SCRIPT_DIR"/init-db.sh "$pathToOkapi"
  "$SCRIPT_DIR"/start-okapi.sh "$pathToOkapi"
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target\n" "$pathToOkapi"
fi