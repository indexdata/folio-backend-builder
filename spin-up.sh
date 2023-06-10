project=$1
pathToOkapi=$2
# -f force, kill, restart okapi if running
# -v validate config
# -c clone and/or compile missing modules
# -o send okapi log to file
okapiPid=$(pgrep -f okapi-core-fat.jar)

if [[ -n "$okapiPid" ]]; then
  printf "Okapi is already running.  (%s)" "$(pgrep -fa okapi-core-fat.jar)"
  printf "\nShut down the running Okapi and install a new?"
  read -r -p ' [y/N]? ' choice
  choice=${choice:-N}
  case "$choice" in
    y|Y) ;;
    *) printf "\nOkay. spin-up cancelled.\n"; exit 1;;
  esac
  printf "Shutting down Okapi.\n"
  pkill -f okapi-core-fat.jar
fi

./folio-service/start.sh "$pathToOkapi"
./install-modulese.sh "$project"

