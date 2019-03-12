workdir=$FOLIO/install-folio-backend

# mod-permissions must be first, other modules need to write permissions to it
echo mod-permissions 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-permissions/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-permissions
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-permissions.json http://localhost:9130/_/discovery/modules
echo Assign mod-permissions to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-permissions-5.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo Assign internal module to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "okapi-2.22.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users.json http://localhost:9130/_/discovery/modules
echo Assign mod-users to diku
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-15.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-login 
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-login/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-login
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-login.json http://localhost:9130/_/discovery/modules
echo Assign mod-login to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-login-4.5.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-password-validator/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-password-validator
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-password-validator.json http://localhost:9130/_/discovery/modules
echo Assign mod-password-validator to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-password-validator-1.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-storage.json http://localhost:9130/_/discovery/modules
echo Install mod-inventory-storage for diku
curl -w '\n' -X POST -d '[ { "id": "mod-inventory-storage-15.2.0-SNAPSHOT", "action": "enable" } ]' http://localhost:9130/_/proxy/tenants/diku/install?tenantParameters=loadReference%3Dtrue

echo mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-users-bl/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-users-bl
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$workdir/deployment-descriptors/DeploymentDescriptor-mod-users-bl.json http://localhost:9130/_/discovery/modules
echo Assign mod-users-bl to DIKU
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-4.0.4-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo register mod-authtoken
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-authtoken/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules

echo mod-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-inventory-11.2.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-inventory
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-inventory/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-codex-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-inventory.json http://localhost:9130/_/discovery/modules
echo Assign mod-codex-inventory
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-inventory-1.4.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-codex-mux
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-codex-mux/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-codex-mux
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-codex-mux.json http://localhost:9130/_/discovery/modules
echo Assign mod-codex-mux
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-codex-mux-2.2.3-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-calendar
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-calendar/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-calendar
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-calendar.json http://localhost:9130/_/discovery/modules
echo Assign mod-calendar
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-calendar-1.3.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation-storage
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-circulation-storage.json http://localhost:9130/_/discovery/modules
echo Assign mod-circulation-storage
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-circulation-storage/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-circulation
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-circulation
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-circulation.json http://localhost:9130/_/discovery/modules
echo Assign mod-circulation
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-circulation/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-rtac
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-rtac/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-rtac
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-rtac.json http://localhost:9130/_/discovery/modules
echo Assign mod-rtac
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-rtac-1.2.2-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

#echo mod-patron (requires fees and fines to install)
#curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-patron/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
#echo Deploy mod-patron
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-patron.json http://localhost:9130/_/discovery/modules
#echo Assign mod-patron
#curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-patron-1.2.0-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-configuration
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-configuration/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-configuration
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/DeploymentDescriptor-mod-configuration.json http://localhost:9130/_/discovery/modules
echo Assign mod-configuration
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-configuration-3.0.1-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-notify
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-notify
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-notify/target/DeploymentDescriptor.json http://localhost:9130/_/discovery/modules
echo Assign mod-notify
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d '{"id": "mod-notify-1.1.6-SNAPSHOT"}' http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-union-catalog
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-union-catalog/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-union-catalog
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-union-catalog.json http://localhost:9130/_/discovery/modules
echo Assign mod-union-catalog
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-union-catalog/target/Activate.json http://localhost:9130/_/proxy/tenants/diku/modules

echo mod-inventory-match
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$FOLIO/mod-inventory-match/target/ModuleDescriptor.json http://localhost:9130/_/proxy/modules
echo Deploy mod-inventory-match
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/install-folio-backend/other-modules/inventory/DeploymentDescriptor-mod-inventory-match.json http://localhost:9130/_/discovery/modules
echo Assign mod-inventory-match
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @$FOLIO/mod-inventory-match/target/TenantModuleDescriptor.json http://localhost:9130/_/proxy/tenants/diku/modules
