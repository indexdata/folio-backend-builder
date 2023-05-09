SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

JAVA_11=/usr/lib/jvm/java-11-openjdk-amd64/bin/java


echo Register mod-pubsub for mod-circulation-storage, mod-feesfines
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-pubsub/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-pubsub
#$FOLIO/install-folio-backend/templates/dd-pg.sh mod-pubsub 2.10.0-SNAPSHOT $JAVA_11 $FOLIO mod-pubsub-server/target/mod-pubsub-server-fat.jar localhost
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-pubsub.json http://localhost:9130/_/discovery/modules
echo Install mod-pubsub for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-pubsub-2.10.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 


echo register mod-circulation-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-circulation-storage 16.1.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-circulation-storage-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-circulation-storage.json http://localhost:9130/_/discovery/modules
echo assign mod-circulation-storage to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-event-config                 for mod-notify
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-event-config/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-event-config
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-event-config-2.6.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-event-config for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-event-config-2.6.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-configuration                for mod-template-engine, mod-email, mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-configuration 5.9.2-SNAPSHOT $JAVA_11 $FOLIO mod-configuration-server/target/mod-configuration-server-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-configuration.json http://localhost:9130/_/discovery/modules
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-configuration-5.9.2-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-configuration-5.9.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-template-engine              for mod-notify
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-template-engine/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-template-engine
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-template-engine 1.19.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-template-engine-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-template-engine.json http://localhost:9130/_/discovery/modules
echo Install mod-template-engine for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-template-engine-1.19.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-email                         for mod-sender
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-email/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-email
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-email 1.15.4-SNAPSHOT $JAVA_11 $FOLIO target/mod-email-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-email.json http://localhost:9130/_/discovery/modules
echo Install mod-email for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-email-1.15.4-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-sender                        for mod-notifiy
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-sender/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-sender
$FOLIO/install-folio-backend/templates/dd-no-pg.sh mod-sender 1.11.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-sender-fat.jar
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-sender.json http://localhost:9130/_/discovery/modules
echo Install mod-sender for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-sender-1.11.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notify                        for mod-feesfines
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
#$FOLIO/install-folio-backend/templates/dd-no-pg.sh mod-notify 3.0.1-SNAPSHOT $JAVA_11 $FOLIO target/mod-notify-fat.jar
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-notify-3.0.1-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notify for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-notify-3.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-feesfines
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-feesfines/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-feesfines
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-feesfines 18.3.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-feesfines-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-feesfines-18.3.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-feesfines.json http://localhost:9130/_/discovery/modules
echo Install mod-feesfines for diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-feesfines-18.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Register mod-calendar                      for mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-calendar/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-calendar-2.4.3-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-calendar-2.4.3-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-patron-blocks                 for mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-patron-blocks/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
$FOLIO/install-folio-backend/templates/dd-pg.sh mod-patron-blocks 1.9.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-patron-blocks-fat.jar localhost
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-patron-blocks-1.9.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-patron-blocks.json http://localhost:9130/_/discovery/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-patron-blocks-1.9.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-notes                         for mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-notes/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"srvcId": "mod-notes-5.1.0-SNAPSHOT", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-notes-5.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo register mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation
#$FOLIO/install-folio-backend/templates/dd-no-pg.sh mod-circulation 23.6.0-SNAPSHOT $JAVA_11 $FOLIO target/mod-circulation.jar
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$workdir/referencing-modules/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
echo assign mod-circulation to diku
curl -w '\n'         -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read 
