workdir=$FOLIO/install-folio-backend
GITOLE=/home/ne/git-ole
GITID=/home/ne/gitprojects


echo Assign internal module to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "okapi-3.1.3"}' http://localhost:9130/_/proxy/tenants/diku/modules

# Set up faux APIs to stand in for required module dependencies that the shared index don't use
echo mod-shared-index-muted-apis
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-shared-index-muted-apis
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-shared-index-muted-apis.json http://localhost:9130/_/discovery/modules
echo Assign mod-shared-index-muted-apis
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$GITOLE/mod-shared-index-muted-apis/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules


# mod-permissions must be before any modules requiring permissions, those modules need to write permissions to it
echo mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-permissions.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-permissions-5.12.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-users-16.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-login.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-login-7.1.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-password-validator.json http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-password-validator-1.4.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-storage.json http://localhost:9130/_/discovery/modules
echo Install mod-inventory-storage for diku
curl -w '\n' -X POST -d '[ { "id": "mod-inventory-storage-20.0.0-SNAPSHOT", "action": "enable" } ]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue

echo register mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-configuration
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-configuration
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-configuration.json http://localhost:9130/_/discovery/modules
echo Assign mod-configuration
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-configuration-5.0.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-update
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-update/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-update
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-update.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory-update
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-update/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-marc-storage proxy
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$GITOLE/mod-marc-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-marc-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-marc-storage.json http://localhost:9130/_/discovery/modules
echo Assign mod-marc-storage
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d '{"id": "mod-marc-storage-0.0.5-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-harvester-admin
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$GITID/mod-harvester-admin/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-harvester-admin
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/harvester/DeploymentDescriptor-mod-harvester-admin.json http://localhost:9130/_/discovery/modules
#echo Assign mod-harvester-admin
#curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @$GITID/mod-harvester-admin/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules

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
#
#            Replaced by no-op API stand-ins
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
