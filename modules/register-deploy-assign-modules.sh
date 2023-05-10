SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
GITOLE=~/git-ole
GITID=~/gitprojects
GITFOLIO=$FOLIO
DEPLOY=$FOLIO/install-folio-backend/deploy

JAVA_11=/usr/lib/jvm/java-11-openjdk-amd64/bin/java

# Installed modules                           ## Required for

V_MOD_SHARED_INDEX_MUTED_APIS="1.0-SNAPSHOT"  ## (source-storage-records, instance-authority-links for inventory)
V_MOD_PERMISSIONS="6.4.0-SNAPSHOT"            ## users-bl, pubsub, authtoken
V_MOD_INVENTORY_STORAGE="26.1.0-SNAPSHOT"     ## circulation, inventory, feesfines, circulation-storage
V_MOD_USERS="19.2.0-SNAPSHOT"                 ## circulation, inventory, notes, feesfines, notify, sender, users-bl, pubsub, authtoken, login
V_MOD_LOGIN="7.10.0-SNAPSHOT"                 ## users-bl, pubsub
V_MOD_PASSWORD_VALIDATOR="3.1.0-SNAPSHOT"     ## users-bl
V_MOD_AUTHTOKEN="2.14.0-SNAPSHOT"             ## users-bl
V_MOD_PUBSUB="2.10.0-SNAPSHOT"                ## circulation, feesfines, circulation-storage
V_MOD_CIRCULATION_STORAGE="16.1.0-SNAPSHOT"   ## circulation, inventory, feesfines, template-engine
V_MOD_EVENT_CONFIG="2.6.0-SNAPSHOT"           ## notify
V_MOD_CONFIGURATION="5.9.2-SNAPSHOT"          ## circulation, notes, email, template-engine, users-bl
V_MOD_USERS_BL="7.6.0-SNAPSHOT"               ## (to login)
V_MOD_TEMPLATE_ENGINE="1.19.0-SNAPSHOT"       ## notify
V_MOD_EMAIL="1.15.4-SNAPSHOT"                 ## sender
V_MOD_SENDER="1.11.0-SNAPSHOT"                ## notify
V_MOD_NOTIFY="3.0.1-SNAPSHOT"                 ## feesfines
V_MOD_FEESFINES="18.3.0-SNAPSHOT"             ## circulation  
V_MOD_PATRON_BLOCKS="1.9.0-SNAPSHOT"          ## circulation
V_MOD_CALENDAR="2.4.3-SNAPSHOT"               ## circulation
V_MOD_NOTES="5.1.0-SNAPSHOT"                  ## circulation
V_MOD_CIRCULATION=""                          ## (ui)
V_MOD_INVENTORY="20.1.0-SNAPSHOT"             ## (ui)

# Set up faux APIs to stand in for required module dependencies that the shared index don't use
echo Register mod-shared-index-muted-apis
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-shared-index-muted-apis
$DEPLOY/dd-no-pg.sh mod-shared-index-muted-apis $V_MOD_SHARED_INDEX_MUTED_APIS $JAVA_11 $GITOLE target/mod-shared-index-muted-apis-fat.jar 
echo Assign mod-shared-index-muted-apis to diku
curl -w '\n' -D -     -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

# mod-permissions must come before any modules requiring permissions; those modules need to write permissions to it
echo mod-permissions
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
$DEPLOY/dd-pg.sh mod-permissions $V_MOD_PERMISSIONS $JAVA_11 $GITFOLIO target/mod-permissions-fat.jar localhost
echo Install mod-permissions for DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-permissions-'$V_MOD_PERMISSIONS'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-inventory-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
$DEPLOY/dd-pg.sh mod-inventory-storage $V_MOD_INVENTORY_STORAGE $JAVA_11 $GITFOLIO target/mod-inventory-storage-fat.jar localhost
echo Install mod-inventory-storage for diku
curl -w '\n'          -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue%2CloadSample%3Dtrue
#echo enter; read

echo Register mod-users
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
$DEPLOY/dd-pg-kafka.sh mod-users $V_MOD_USERS $JAVA_11 $GITFOLIO target/mod-users-fat.jar localhost
echo Install mod-users for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-users-'$V_MOD_USERS'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-login
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
$DEPLOY/dd-pg.sh mod-login $V_MOD_LOGIN $JAVA_11 $GITFOLIO target/mod-login-fat.jar localhost
echo Assign mod-login to DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-login-'$V_MOD_LOGIN'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-password-validator
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-password-validator-'$V_MOD_PASSWORD_VALIDATOR'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-password-validator-'$V_MOD_PASSWORD_VALIDATOR'"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo register mod-authtoken
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-authtoken
$DEPLOY/dd-pg.sh mod-authtoken $V_MOD_AUTHTOKEN $JAVA_11 $FOLIO target/mod-authtoken-fat.jar localhost
#echo enter; read

echo Register mod-pubsub
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-pubsub/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-pubsub
curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-pubsub.json http://localhost:9130/_/discovery/modules
echo Install mod-pubsub for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-pubsub-'$V_MOD_PUBSUB'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 

echo Register mod-circulation-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
$DEPLOY/dd-pg.sh mod-circulation-storage $V_MOD_CIRCULATION_STORAGE $JAVA_11 $FOLIO target/mod-circulation-storage-fat.jar localhost
echo Install mod-circulation-storage for diku
curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-event-config
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-event-config/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-event-config
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-event-config-'$V_MOD_EVENT_CONFIG'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-event-config for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-event-config-'$V_MOD_EVENT_CONFIG'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-configuration
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
$DEPLOY/dd-pg.sh mod-configuration $V_MOD_CONFIGURATION $JAVA_11 $FOLIO mod-configuration-server/target/mod-configuration-server-fat.jar localhost
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-configuration-'$V_MOD_CONFIGURATION'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users-bl/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users-bl
$DEPLOY/dd-pg.sh mod-users-bl $V_MOD_USERS_BL $JAVA_11 $FOLIO target/mod-users-bl-fat.jar localhost
#echo enter; read

echo Register mod-template-engine
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-template-engine/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-template-engine
$DEPLOY/dd-pg.sh mod-template-engine $V_MOD_TEMPLATE_ENGINE $JAVA_11 $FOLIO target/mod-template-engine-fat.jar localhost
echo Install mod-template-engine for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-template-engine-'$V_MOD_TEMPLATE_ENGINE'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-email
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-email/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-email
$DEPLOY/dd-pg.sh mod-email $V_MOD_EMAIL $JAVA_11 $FOLIO target/mod-email-fat.jar localhost
echo Install mod-email for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-email-'$V_MOD_EMAIL'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-sender
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-sender/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-sender
$DEPLOY/dd-no-pg.sh mod-sender $V_MOD_SENDER $JAVA_11 $FOLIO target/mod-sender-fat.jar
echo Install mod-sender for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-sender-'$V_MOD_SENDER'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notify
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notify-'$V_MOD_NOTIFY'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notify for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notify-'$V_MOD_NOTIFY'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-feesfines
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-feesfines/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-feesfines
$DEPLOY/dd-pg.sh mod-feesfines $V_MOD_FEESFINES $JAVA_11 $FOLIO target/mod-feesfines-fat.jar localhost
echo Install mod-feesfines for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-feesfines-'$V_MOD_FEESFINES'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-calendar
curl -w '\n' -D - -s  "Content-type: application/json" -d @$GITFOLIO/mod-calendar/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-calendar
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-calendar-'$V_MOD_CALENDAR'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-calendar for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-calendar-'$V_MOD_CALENDAR'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 

echo Register mod-patron-blocks
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-patron-blocks/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-patron-blocks
$DEPLOY/dd-pg.sh mod-patron-blocks $V_MOD_PATRON_BLOCKS $JAVA_11 $FOLIO target/mod-patron-blocks-fat.jar localhost
echo Install mod-patron-blocks for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-patron-blocks-'$V_MOD_PATRON_BLOCKS'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notes                         
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notes/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notes
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notes-'$V_MOD_NOTES'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notes for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notes-'$V_MOD_NOTES'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

if [[ -v V_MOD_CIRCULATION ]]; then
    echo Register mod-circulation
    curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
    echo Deploy mod-circulation
    curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
    echo Install mod-circulation for diku
    curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules
    #echo enter; read 
else 
    echo "
    ************************
    Skipping mod-circulation
    ************************
    "
fi

if [[ -v V_MOD_INVENTORY ]]; then
    echo Register mod-inventory
    curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
    echo Deploy mod-inventory
    $DEPLOY/dd-pg-kafka.sh mod-inventory $V_MOD_INVENTORY $JAVA_11 $GITFOLIO target/mod-inventory.jar localhost
    echo Install mod-inventory for diku
    curl -w '\n' -D -     -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules
    #echo enter; read 
else
    echo "
    **********************
    Skipping mod-inventory
    **********************
    "
fi
