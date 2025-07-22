here=${0%/*}
pathToOkapi=~/folio
logToFile=0
logFile=

# Will docker 'up' back-end services, postgres, kafka, elastic search (will docker 'down' them first if already running)
# Will initialize Okapi's database and start Okapi
#   if a logfile name is provided (-l <log file name>) Okapi is started in background with its output spooled to the logfile
#   - otherwise Okapi is started in foreground with output sent to stdout
#   The path to Okapi can be provided as -p <path>, it defaults to `~/folio`
#
# If a postgres service is already running on the host, will offer to shot it down.

while getopts ":p:l:" option; do
   case $option in
      p) # Path to Okapi
         pathToOkapi=$OPTARG;;
      l) # Send output to log file
         logToFile=1
         logFile=${OPTARG:-"okapi.log"};;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
echo "path: $pathToOkapi"

if [ -d "$pathToOkapi"/okapi/okapi-core/target ]; then
  printf "Stopping Docker Postgres and Kafka services if running.\n"
  docker compose -f "$here"/docker-compose.yml down

  # Check if another postgresql might be running on port 5432  
  if [[ "$(nc -z 127.0.0.1 5432; echo $?)" == "0" ]]; then 
    printf "Port 5432 is already in use\n"
    if [[ -n $(pgrep -f postgresql) ]]; then 
      printf "A PostgreSQL service is already running,\n"
      printf "\nShut down the running PostgreSQL service before starting PostgreSQL in container?"
      read -r -p ' [y/N]? ' choice
      choice=${choice:-N}
      case "$choice" in
        y|Y) printf "Attemting to stop PostgreSQL\n"; service postgresql stop ;;
        *) printf "\nOkay. Not stopping PostgreSQL, start up of PostgreSQL in contain might fail.\n"; exit 1;;
      esac
    fi  
  fi    

  printf "Starting Postgres, Kafka, elastic search.\n"
  docker compose -f "$here"/docker-compose.yml up -d
  if [[ $logToFile -eq 1 ]]; then
      "$here"/okapi/init-db-start-okapi.sh "$pathToOkapi" >> "$logFile" 2>&1 &
      printf "Okapi starting ..."
      sleep 20
      if [[ "$(tail -1 "$logFile")" == *supertenant\ ok ]]; then
        pid=$(pgrep -f "okapi-core/target/okapi-core-fat.jar")
        printf "Okapi started in back-ground.\nLogs redirected to '%s'. Okapi PID is [%s] \n\n" "$logFile" "$pid"
      else
        printf "Okapi started in back-ground.\nLogs redirected to '%s'.\n\n" "$logFile"
      fi
  else
     "$here"/okapi/init-db-start-okapi.sh "$pathToOkapi"
  fi
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target.\n" "$pathToOkapi"
fi
