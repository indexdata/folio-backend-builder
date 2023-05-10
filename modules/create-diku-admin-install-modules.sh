# Installs listed modules
# OBS:
# Requires environment variable `FOLIO` to be set to the directory where FOLIO modules are checked out to. 
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

# Path to utility scripts for deploying modules 
DEPLOY=$workdir/deploy

# Git checkout directories for modules and this installation tool
# Okapi and most modules should be checked out from FOLIO at Github
GITFOLIO=$FOLIO
# A single module here resides in OLE's Github
GITOLE=~/git-ole
# Some modules could come from Index Data's Github.
GITID=~/gitprojects

# Most modules compiles and runs using JAVA 11 now.
JAVA_11=/usr/lib/jvm/java-11-openjdk-amd64/bin/java

# Installed modules                           ## Required for

V_MOD_PERMISSIONS="6.4.0-SNAPSHOT"            ## users-bl, pubsub, authtoken
V_MOD_USERS="19.2.0-SNAPSHOT"                 ## circulation, inventory, notes, feesfines, notify, sender, users-bl, pubsub, authtoken, login
V_MOD_LOGIN="7.10.0-SNAPSHOT"                 ## users-bl, pubsub

V_MOD_SHARED_INDEX_MUTED_APIS="1.0-SNAPSHOT"  ## (source-storage-records, instance-authority-links for inventory)
V_MOD_INVENTORY_STORAGE="26.1.0-SNAPSHOT"     ## circulation, inventory, feesfines, circulation-storage
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

# mod-permissions must come before any modules requiring permissions; those modules need to write permissions to it
echo mod-permissions
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
$DEPLOY/dd-pg.sh mod-permissions $V_MOD_PERMISSIONS $JAVA_11 $GITFOLIO target/mod-permissions-fat.jar localhost
echo Install mod-permissions for DIKU
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-permissions-'$V_MOD_PERMISSIONS'"}' http://localhost:9130/_/proxy/tenants/diku/modules
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

echo "
With permissions, users and login deployed, creating user diku_admin in order to assign permissions
"
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d  '{
  "username" : "diku_admin",
  "id" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
  "active" : true,
  "proxyFor" : [ ],
  "personal" : {
    "lastName" : "ADMINISTRATOR",
    "firstName" : "DIKU",
    "email" : "admin@diku.example.org",
    "addresses" : [ ]
  }
}' http://localhost:9130/users

echo "
Assigning password 'admin' to diku_admin
"
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -X POST -d '{ "userId":"1ad737b0-d847-11e6-bf26-cec0c932ce01",
  "password":"admin" }' http://localhost:9130/authn/credentials

echo "
Give diku_admin permissions for perms, login, users
"
PU_ID=$(curl -s -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -d '{
    "userId" : "1ad737b0-d847-11e6-bf26-cec0c932ce01",
    "permissions" : [
      "perms.all",
      "login.all",
      "users.all"
    ]
}' http://localhost:9130/perms/users | jq -r '.id')
#echo Got puId $PU_ID; read


# Set up faux APIs to stand in for required module dependencies that the shared index don't use
echo Register mod-shared-index-muted-apis
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-shared-index-muted-apis
$DEPLOY/dd-no-pg.sh mod-shared-index-muted-apis $V_MOD_SHARED_INDEX_MUTED_APIS $JAVA_11 $GITOLE target/mod-shared-index-muted-apis-fat.jar 
echo Assign mod-shared-index-muted-apis to diku
curl -w '\n' -D -     -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules
#echo enter; read

echo Register mod-inventory-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
$DEPLOY/dd-pg.sh mod-inventory-storage $V_MOD_INVENTORY_STORAGE $JAVA_11 $GITFOLIO target/mod-inventory-storage-fat.jar localhost
echo Install mod-inventory-storage for diku
curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-inventory-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue%2CloadSample%3Dtrue
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "inventory-storage.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
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
$DEPLOY/dd-pg.sh mod-authtoken $V_MOD_AUTHTOKEN $JAVA_11 $GITFOLIO target/mod-authtoken-fat.jar localhost
#echo enter; read

echo Register mod-pubsub
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-pubsub/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-pubsub
curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-pubsub.json http://localhost:9130/_/discovery/modules
echo Install mod-pubsub for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-pubsub-'$V_MOD_PUBSUB'"}' http://localhost:9130/_/proxy/tenants/diku/modules
for perm in pubsub.event-types.get pubsub.event-types.post pubsub.event-types.put pubsub.event-types.delete pubsub.publishers.post pubsub.publishers.delete pubsub.publishers.get pubsub.subscribers.post pubsub.subscribers.delete pubsub.subscribers.get pubsub.audit.history.get pubsub.audit.message.payload.get pubsub.publish.post pubsub.messaging-modules.delete pubsub.events.post; do
    curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json"  -d '{"permissionName": "'$perm'"}' http://localhost:9130/perms/users/$PU_ID/permissions
done
#echo enter; read 

echo Register mod-circulation-storage
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
$DEPLOY/dd-pg.sh mod-circulation-storage $V_MOD_CIRCULATION_STORAGE $JAVA_11 $GITFOLIO target/mod-circulation-storage-fat.jar localhost
echo Install mod-circulation-storage for diku
curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation-storage/target/Install.json http://localhost:9130/_/proxy/tenants/diku/modules
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "circulation-storage.all"}' http://localhost:9130/perms/users/$PU_ID/permissions

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
echo Deploy mod-configuration
$DEPLOY/dd-pg.sh mod-configuration $V_MOD_CONFIGURATION $JAVA_11 $GITFOLIO mod-configuration-server/target/mod-configuration-server-fat.jar localhost
echo Install mod-configuration for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-configuration-'$V_MOD_CONFIGURATION'"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Permit configuration for diku_admin
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "configuration.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

echo Register mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$GITFOLIO/mod-users-bl/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users-bl
$DEPLOY/dd-pg.sh mod-users-bl $V_MOD_USERS_BL $JAVA_11 $GITFOLIO target/mod-users-bl-fat.jar localhost
#echo enter; read

echo Register mod-template-engine
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-template-engine/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-template-engine
$DEPLOY/dd-pg.sh mod-template-engine $V_MOD_TEMPLATE_ENGINE $JAVA_11 $GITFOLIO target/mod-template-engine-fat.jar localhost
echo Install mod-template-engine for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-template-engine-'$V_MOD_TEMPLATE_ENGINE'"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Give diku_admin permissions to template-engine
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "templates.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

echo Register mod-email
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-email/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-email
$DEPLOY/dd-pg.sh mod-email $V_MOD_EMAIL $JAVA_11 $GITFOLIO target/mod-email-fat.jar localhost
echo Install mod-email for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-email-'$V_MOD_EMAIL'"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Give diku_admin permission for email
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "email.message.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "email.smtp-configuration.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

echo Register mod-sender
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-sender/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-sender
$DEPLOY/dd-no-pg.sh mod-sender $V_MOD_SENDER $JAVA_11 $GITFOLIO target/mod-sender-fat.jar
echo Install mod-sender for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-sender-'$V_MOD_SENDER'"}' http://localhost:9130/_/proxy/tenants/diku/modules
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "sender.message-delivery"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

echo Register mod-notify
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notify-'$V_MOD_NOTIFY'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notify for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notify-'$V_MOD_NOTIFY'"}' http://localhost:9130/_/proxy/tenants/diku/modules
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "notify.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

echo Register mod-feesfines
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-feesfines/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-feesfines
$DEPLOY/dd-pg.sh mod-feesfines $V_MOD_FEESFINES $JAVA_11 $GITFOLIO target/mod-feesfines-fat.jar localhost
echo Install mod-feesfines for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-feesfines-'$V_MOD_FEESFINES'"}' http://localhost:9130/_/proxy/tenants/diku/modules
for perm in feefines.collection.get feefines.item.get feefines.item.post feefines.item.put feefines.item.delete owners.collection.get owners.item.get owners.item.post owners.item.put owners.item.delete accounts.collection.get accounts.item.get accounts.item.post accounts.item.put accounts.item.delete accounts.check-pay.post accounts.check-waive.post accounts.check-transfer.post accounts.check-refund.post accounts.pay.post accounts.waive.post accounts.transfer.post accounts.cancel.post accounts.refund.post feefineactions.collection.get feefineactions.item.get feefineactions.item.post feefineactions.item.put feefineactions.item.delete payments.collection.get payments.item.get payments.item.post accounts.pay.check.post payments.item.put payments.item.delete waives.collection.get waives.item.get waives.item.post waives.item.put waives.item.delete refunds.collection.get refunds.item.get refunds.item.post refunds.item.put refunds.item.delete transfers.collection.get transfers.item.get transfers.item.post transfers.item.put transfers.item.delete comments.collection.get comments.item.get comments.item.post comments.item.put comments.item.delete transfer-criterias.collection.get transfer-criterias.item.get transfer-criterias.item.post transfer-criterias.item.put transfer-criterias.item.delete manualblocks.collection.get manualblocks.item.get manualblocks.item.post manualblocks.item.put manualblocks.item.delete overdue-fines-policies.collection.get overdue-fines-policies.item.get overdue-fines-policies.item.post overdue-fines-policies.item.put overdue-fines-policies.item.delete lost-item-fees-policies.collection.get lost-item-fees-policies.item.get lost-item-fees-policies.item.post lost-item-fees-policies.item.put lost-item-fees-policies.item.delete manual-block-templates.collection.get manual-block-templates.item.get manual-block-templates.item.post manual-block-templates.item.put manual-block-templates.item.delete modperms.feesfines.patron-notices.post feefine-reports.refund.post feefine-reports.cash-drawer-reconciliation.post feefine-reports.financial-transactions-detail.post actual-cost-fee-fine-cancel.post actual-cost-fee-fine-bill.post; do
  curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json"  -d '{"permissionName": "'$perm'"}' http://localhost:9130/perms/users/$PU_ID/permissions
done
#echo enter; read

echo Register mod-calendar
curl -w '\n' -D - -s  "Content-type: application/json" -d @$GITFOLIO/mod-calendar/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-calendar
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-calendar-'$V_MOD_CALENDAR'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-calendar for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-calendar-'$V_MOD_CALENDAR'"}' http://localhost:9130/_/proxy/tenants/diku/modules
echo Permit mod-calendar for diku_admin
curl -X POST -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "calendar.create"}' http://localhost:9130/perms/users/$PU_ID/permissions
curl -X POST -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "calendar.update"}' http://localhost:9130/perms/users/$PU_ID/permissions
curl -X POST -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "calendar.delete"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read 

echo Register mod-patron-blocks
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-patron-blocks/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-patron-blocks
$DEPLOY/dd-pg.sh mod-patron-blocks $V_MOD_PATRON_BLOCKS $JAVA_11 $GITFOLIO target/mod-patron-blocks-fat.jar localhost
echo Install mod-patron-blocks for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-patron-blocks-'$V_MOD_PATRON_BLOCKS'"}' http://localhost:9130/_/proxy/tenants/diku/modules
for perm in patron-block-conditions.collection.get patron-block-conditions.item.get patron-block-conditions.item.put patron-block-limits.collection.get patron-block-limits.item.get patron-block-limits.item.post patron-block-limits.item.put patron-block-limits.item.delete automated-patron-blocks.collection.get user-summary.item.get patron-blocks.synchronization.job.post patron-blocks.synchronization.job.get; do
  curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json"  -d '{"permissionName": "'$perm'"}' http://localhost:9130/perms/users/$PU_ID/permissions
done
#echo enter; read

echo Register mod-notes                         
curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-notes/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notes
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"srvcId": "mod-notes-'$V_MOD_NOTES'", "nodeId": "localhost"}' http://localhost:9130/_/discovery/modules
echo Install mod-notes for diku
curl -w '\n' -D -     -H "Content-type: application/json" -d '{"id": "mod-notes-'$V_MOD_NOTES'"}' http://localhost:9130/_/proxy/tenants/diku/modules
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "notes.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
#echo enter; read

if [[ -v V_MOD_CIRCULATION ]]; then
    echo Register mod-circulation
    curl -w '\n' -D - -s  -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
    echo Deploy mod-circulation
    curl -w '\n' -D -     -H "Content-type: application/json" -d @$workdir/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
    echo Install mod-circulation for diku
    curl -w '\n'          -H "Content-type: application/json" -d @$GITFOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules
    echo Permit circulation for diku_admin
    curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
     -d '{"permissionName": "circulation.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
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
    echo Permit inventory for diku_admin
    curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" \
      -d '{"permissionName": "inventory.all"}' http://localhost:9130/perms/users/$PU_ID/permissions
    #echo enter; read 
else
    echo "
    **********************
    Skipping mod-inventory
    **********************
    "
fi

