SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

printf "Shutting down Okapi (if running).\n"
pkill -f okapi-core-fat.jar
printf "Shut down supporting services (database, messaging, etc)\n"
docker compose -f "$SCRIPT_DIR"/docker-compose.yml down
