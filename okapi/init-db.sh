# Initializing Okapi database
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1
if [ -d "$pathToOkapi/okapi/okapi-core/target" ]; then
  java -Dport=8600 -Dstorage=postgres -jar "$pathToOkapi"/okapi/okapi-core/target/okapi-core-fat.jar initdatabase
else
  printf "Could not find Okapi installation at %s\n" "$pathToOkapi/okapi/okapi-core/target"
fi
