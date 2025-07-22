here=${0%/*}
pathToOkapi=~/folio
logToFile=0
logFile=

while getopts ":p:o:" option; do
   case $option in
      p) # Path to Okapi
         pathToOkapi=$OPTARG;;
      o) # Send output to log file
         logToFile=1
         logFile=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [ -d "$pathToOkapi"/okapi/okapi-core/target ]; then
  printf "Starting Postgres, Kafka, elastic search.\n"
  docker compose -f "$here"/docker-compose.yml unpause
  if [[ $logToFile -eq 1 ]]; then
      "$here"/okapi/start-okapi.sh "$pathToOkapi" >> "$logFile" 2>&1 &
      printf "Okapi starting ..."
      sleep 20
      if [[ "$(tail -1 "$logFile")" == *supertenant\ ok ]]; then
        pid=$(pgrep -f "okapi-core/target/okapi-core-fat.jar")
        printf "Okapi started in back-ground.\nLogs redirected to '%s'. Okapi PID is [%s] \n\n" "$logFile" "$pid"
      else
        printf "Okapi started in back-ground.\nLogs redirected to '%s'.\n\n" "$logFile"
      fi
  else
     "$here"/okapi/start-okapi.sh "$pathToOkapi"
  fi
else
  printf "Could not find Okapi installation at %s/okapi/okapi-core/target.\n" "$pathToOkapi"
fi
