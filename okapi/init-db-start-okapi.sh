# Initializes (empties) Okapi's database (tenants and modules)
# Starts Okapi
# Creates the 'diku' tenant.

java -Dport=8600 -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar initdatabase

$FOLIO/install-folio-backend/okapi/start-okapi.sh
