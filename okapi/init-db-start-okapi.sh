# Initializes (empties) Okapi's database (tenants and modules)
# Starts Okapi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

clear

$SCRIPT_DIR/init-db.sh

$SCRIPT_DIR/start-okapi.sh
