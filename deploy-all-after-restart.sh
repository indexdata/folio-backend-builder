AUTHN_MODS=$FOLIO/install-folio-backend/deployment-descriptors
OTHER_MODS=$FOLIO/install-folio-backend/other-modules/
INVENTORY_MODS=$OTHER_MODS/inventory

# Basic users and permissions modules
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$AUTHN_MODS/DeploymentDescriptor-mod-permissions-5.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$AUTHN_MODS/DeploymentDescriptor-mod-users-14.2.2-SNAPSHOT.json http://localhost:9130/_/discovery/modules

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$AUTHN_MODS/DeploymentDescriptor-mod-login-4.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$AUTHN_MODS/DeploymentDescriptor-mod-users-bl-2.1.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$AUTHN_MODS/DeploymentDescriptor-mod-authtoken-1.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

# Configuration mod
curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$OTHER_MODS/DeploymentDescriptor-mod-configuration-3.0.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

# Inventory

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$INVENTORY_MODS/DeploymentDescriptor-mod-inventory-storage-5.1.1-SNAPSHOT.json http://localhost:9130/_/discovery/modules

curl -w '\n' -D - -s -X POST -H "Content-type: application/json" -d @$INVENTORY_MODS/DeploymentDescriptor-mod-inventory-5.1.2-SNAPSHOT.json http://localhost:9130/_/discovery/modules