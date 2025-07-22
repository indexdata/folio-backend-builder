here=${0%/*}

printf "Shutting down Okapi (if running).\n"
pkill -f okapi-core-fat.jar
printf "Shut down supporting services (database, messaging, etc)\n"
docker compose -f "$here"/docker-compose.yml pause
