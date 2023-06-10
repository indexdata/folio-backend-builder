# Start Okapi
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1
if [ -d "$pathToOkapi" ]; then
  java -Dport_start=9152 -Dport_end=9199 -Dstorage=postgres -jar "$pathToOkapi"/okapi/okapi-core/target/okapi-core-fat.jar dev
else
  printf "Could not find Okapi installation at %s\n" "$pathToOkapi"
fi
