SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pathToOkapi=${1:-${FOLIO:-~/folio}}  # path from ~/folio, $FOLIO, or $1

if [ -d "$pathToOkapi/okapi/okapi-core/target" ]; then
  printf "Stop Postgres and Kafka Docker service.\n"
  docker compose -f "$SCRIPT_DIR"/docker-compose.yml down
  printf "Starting Postgres and Kafka.\n"
  docker compose -f "$SCRIPT_DIR"/docker-compose.yml up -d
  "$SCRIPT_DIR"/okapi/init-db-start-okapi.sh "$pathToOkapi" >> okapi.log 2>&1 &
  printf "Okapi starting ..."
  sleep 10
  if [[ "$(tail -1 okapi.log)" == *supertenant\ ok ]]; then
    pid=$(pgrep -f "okapi-core/target/okapi-core-fat.jar")
    printf "Okapi started in back-ground.\nLogs redirected to '%s'. Okapi PID is [%s] \n\n" "$SCRIPT_DIR/okapi.log" "$pid"
  else
    printf "Okapi started in back-ground.\nLogs redirected to '%s'.\n\n" "$SCRIPT_DIR/okapi.log"
  fi
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target\n" "$pathToOkapi"
fi
