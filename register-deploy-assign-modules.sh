workdir=$FOLIO/install-folio-backend

echo Assign internal module to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "okapi-2.33.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

# mod-permissions must be first, other modules need to write permissions to it
echo mod-permissions 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-permissions.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-permissions-5.9.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules


echo mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-15.7.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-login 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-login.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-login-6.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-password-validator.json http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-password-validator-1.4.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-storage.json http://localhost:9130/_/discovery/modules
echo Install mod-inventory-storage for diku
curl -w '\n' -X POST -d '[ { "id": "mod-inventory-storage-17.1.0-SNAPSHOT", "action": "enable" } ]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue

echo register mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-source-record-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-source-record-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-source-record-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-source-record-storage.json http://localhost:9130/_/discovery/modules
echo Assign mod-source-record-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-source-record-storage-2.7.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-codex-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-codex-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-inventory-1.6.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-mux
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-mux/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-codex-mux
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-mux.json http://localhost:9130/_/discovery/modules
echo Assign mod-codex-mux
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-mux-2.2.3-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-circulation-storage.json http://localhost:9130/_/discovery/modules
echo Assign mod-circulation-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-circulation-storage-9.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-configuration
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-configuration
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-configuration.json http://localhost:9130/_/discovery/modules
echo Assign mod-configuration
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-configuration-5.0.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-event-config
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-event-config/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-event-config
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-event-config.json http://localhost:9130/_/discovery/modules
echo Assign mod-event
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-event-config-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-template-engine
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-template-engine/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-template-engine
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-template-engine.json http://localhost:9130/_/discovery/modules
echo Assign mod-template-engine
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-template-engine-1.7.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-email
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-email/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-email
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-email.json http://localhost:9130/_/discovery/modules
echo Assign mod-email
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-email-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-sender
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-sender/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-sender
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-sender.json http://localhost:9130/_/discovery/modules
echo Assign mod-sender
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-sender-1.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-notify
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-notify.json http://localhost:9130/_/discovery/modules
echo Assign mod-notify
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-notify-2.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-feesfines
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-feesfines/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-feesfines
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-feesfines.json http://localhost:9130/_/discovery/modules
#echo Assign mod-feesfines
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-feesfines-15.4.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-circulation
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-circulation
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
#echo Assign mod-circulation
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-rtac
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-rtac/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-rtac
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-rtac.json http://localhost:9130/_/discovery/modules
#echo Assign mod-rtac
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-rtac-1.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-patron
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-patron/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-patron
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-patron.json http://localhost:9130/_/discovery/modules
#echo Assign mod-patron
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-patron-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-union-catalog
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-union-catalog/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-union-catalog
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-union-catalog.json http://localhost:9130/_/discovery/modules
#echo Assign mod-union-catalog
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-union-catalog/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-match
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-match/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-match
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-match.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory-match
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-inventory-match/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-marc-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-marc-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-marc-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-marc-storage.json http://localhost:9130/_/discovery/modules
echo Assign mod-marc-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-marc-storage-0.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

# Note: Many of these modules are required due to the dependency tree of mod-users-bl
# mod-users-bl
#  requires: /users/ [mod-users]
#
#            /permissions/ [mod-permissions]

#            /login/ [mod-login]
#             [mod-login] requires: users [mod-users]
#
#            /service-points/ [mod-inventory-storage]    
#
#            /service-points-users/ [mod-inventory-storage]
#
#            /password-validator/ [mod-password-validator]
#             [mod-password-validator] requires: /users/ [mod-users]
#
#            /authtoken/ [mod-authtoken]
#             [mod-authtoken] requires: /permissions/ [mod-permissions]
#
#            /notify/ [mod-notify]
#             [mod-notify] requires: /users/ [mod-users]
#                                    /mod-event/ [mod-event-config]
#                                    /template-engine/ [mod-template-engine]
#                                     [mod-template-engine] requires: /patron-notice-policy-storage/ [mod-circulation-storage]
#                                    /message-delivery/ [mod-sender]
#                                     [mod-sender] requires: /users/ [mod-users]
#                                                            /email/ [mod-email]    
#                                                             [mod-email] requires: /configuration/ [mod-configuration]
#
#            /configuration/ [mod-configuration]
