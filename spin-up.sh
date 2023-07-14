project=${*: -1}
pathToOkapi=~/folio

# -f force, stop okapi if already running
# -v validate config before installing
# -c clone and/or compile missing modules
# -l file to send okapi log to (default "okapi.log)
# -p path to okapi check-out (default "~/folio")

stopOkapi=0
validateConfig=0
cloneAndCompile=0

while getopts ":fvcl:o:" option; do
   case $option in
      f) # Stop currently running Okapi 
         stopOkapi=1;;
      v) # Validate config first
         validateConfig=1;;
      c) # Clone and compile missing modules if any
         cloneAndCompile=1;;
      l) # log file to send Okapi logs to
         logFile=$OPTARG;;
      o) # Path to Okapi
          pathToOkapi=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

okapiPid=$(pgrep -f okapi-core-fat.jar)

if [[ $validateConfig -eq 1 ]]; then
  ./validate-config.sh "$project"
  printf "Press Enter to continue "; read -r;
fi
if [[ $cloneAndCompile  -eq 1 ]]; then
  ./clone-and-compile-modules.sh "$project"
fi
if [[ -n "$okapiPid" ]]; then
  if [[ $stopOkapi -eq 0 ]]; then
    printf "Okapi is already running.  (%s)" "$(pgrep -fa okapi-core-fat.jar)"
    printf "\nShut down the running Okapi and install a new?"
    read -r -p ' [y/N]? ' choice
    choice=${choice:-N}
    case "$choice" in
      y|Y) ;;
      *) printf "\nOkay. spin-up cancelled.\n"; exit 1;;
    esac
  fi
  printf "Shutting down Okapi.\n"
  pkill -f okapi-core-fat.jar
fi
printf "Start FOLIO service, Okapi at '%s', sending log to %s\n" "$pathToOkapi" "$logFile"
./folio-service/start.sh -p "$pathToOkapi" -o "$logFile"
printf "Installing modules\n"
./install-modules.sh "$project"
