# Initializes (empties) Okapi's database (tenants and modules)
# Starts Okapi
here=${0%/*}
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1

if [ -d "$pathToOkapi/okapi/okapi-core/target" ]; then
  "$here"/init-db.sh "$pathToOkapi"
  "$here"/start-okapi.sh "$pathToOkapi"
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target\n" "$pathToOkapi"
fi