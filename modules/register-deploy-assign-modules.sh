SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
GITOLE=~/git-ole
GITID=~/gitprojects
GITFOLIO=$FOLIO

JAVA_11=/usr/lib/jvm/java-11-openjdk-amd64/bin/java

# Set up faux APIs to stand in for required module dependencies that the shared index don't use
echo mod-shared-index-muted-apis
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-shared-index-muted-apis
$FOLIO/install-folio-backend/deploy/dd-no-pg.sh mod-shared-index-muted-apis 1.0-SNAPSHOT $JAVA_11 $GITOLE target/mod-shared-index-muted-apis-fat.jar 
echo Assign mod-shared-index-muted-apis to diku
curl -w '\n' -D -     -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

# mod-permissions must come before any modules requiring permissions; those modules need to write permissions to it
echo mod-permissions
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-permissions 6.4.0-SNAPSHOT $JAVA_11 $GITFOLIO target/mod-permissions-fat.jar localhost
echo Assign mod-permissions to DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-permissions-6.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-inventory-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-inventory-storage 26.1.0-SNAPSHOT $JAVA_11 $GITFOLIO target/mod-inventory-storage-fat.jar localhost
echo Install mod-inventory-storage to diku
curl -w '\n'          -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue%2CloadSample%3Dtrue
#echo enter; read

echo mod-users
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
$FOLIO/install-folio-backend/deploy/dd-pg-kafka.sh mod-users 19.2.0-SNAPSHOT $JAVA_11 $GITFOLIO target/mod-users-fat.jar localhost
echo Assign mod-users to diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-users-19.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo mod-login
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-login 7.10.0-SNAPSHOT $JAVA_11 $GITFOLIO target/mod-login-fat.jar localhost
echo Assign mod-login to DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-login-7.10.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo mod-password-validator
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
#curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$workdir/users-and-auth/DeploymentDescriptor-mod-password-validator.json http://localhost:9130/_/discovery/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-password-validator-3.1.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-password-validator-3.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo register mod-authtoken
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo enter; read

echo Register mod-pubsub for mod-circulation-storage, mod-feesfines
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-pubsub/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-pubsub
#$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-pubsub 2.10.0-SNAPSHOT $JAVA_11 $FOLIO mod-pubsub-server/target/mod-pubsub-server-fat.jar localhost
curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-pubsub.json http://localhost:9130/_/discovery/modules
echo Install mod-pubsub for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-pubsub-2.10.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 

echo register mod-circulation-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-circulation-storage 16.1.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-circulation-storage-fat.jar localhost
echo assign mod-circulation-storage to diku
curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-event-config                 for mod-notify
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-event-config/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-event-config
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-event-config-2.6.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-event-config for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-event-config-2.6.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-configuration                for mod-template-engine, mod-email, mod-circulation
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-configuration 5.9.2-SNAPSHOT $JAVA_11 $FOLIO mod-configuration-server/target/mod-configuration-server-fat.jar localhost
#curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-configuration-5.9.2-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-configuration-5.9.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-template-engine              for mod-notify
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-template-engine/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-template-engine
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-template-engine 1.19.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-template-engine-fat.jar localhost
echo Install mod-template-engine for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-template-engine-1.19.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-email                         for mod-sender
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-email/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-email
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-email 1.15.4-SNAPSHOT $JAVA_11 $FOLIO target/mod-email-fat.jar localhost
echo Install mod-email for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-email-1.15.4-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-sender                        for mod-notifiy
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-sender/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-sender
$FOLIO/install-folio-backend/deploy/dd-no-pg.sh mod-sender 1.11.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-sender-fat.jar
echo Install mod-sender for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-sender-1.11.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notify                        for mod-feesfines
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
#$FOLIO/install-folio-backend/deploy/dd-no-pg.sh mod-notify 3.0.1-SNAPSHOT $JAVA_11 $FOLIO target/mod-notify-fat.jar
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notify-3.0.1-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notify for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notify-3.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-feesfines
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-feesfines/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-feesfines
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-feesfines 18.3.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-feesfines-fat.jar localhost
#curl -w '\n' -D -    -H "Content-type: application/json" -d '{"srvcId": "mod-feesfines-18.3.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-feesfines for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-feesfines-18.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-calendar                      for mod-circulation
curl -w '\n' -D - -s  "Content-type: application/json" -d @$GITFOLIO/mod-calendar/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-calendar-2.4.3-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-calendar-2.4.3-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-patron-blocks                 for mod-circulation
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-patron-blocks/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
$FOLIO/install-folio-backend/deploy/dd-pg.sh mod-patron-blocks 1.9.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-patron-blocks-fat.jar localhost
#curl -w '\n' -D -    -H "Content-type: application/json" -d '{"srvcId": "mod-patron-blocks-1.9.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-patron-blocks-1.9.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notes                         for mod-circulation
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notes/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notes-5.1.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notes-5.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo register mod-circulation
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation
curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
echo assign mod-circulation to diku
curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 

echo mod-inventory
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory
$FOLIO/install-folio-backend/deploy/dd-pg-kafka.sh mod-inventory 20.1.0-SNAPSHOT $JAVA_11 $GITFOLIO target/mod-inventory.jar localhost
echo Assign mod-inventory to diku
curl -w '\n' -D -     -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules


date