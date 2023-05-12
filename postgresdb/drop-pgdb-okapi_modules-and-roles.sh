DROP_ROLE() {
  echo "dropping role '$1'"
  sudo -u postgres bash -c "PGPASSWORD=post psql -c \"DROP ROLE IF EXISTS $1;\""
}
echo "Dropping database 'okapi_modules' and roles if exists."
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"DROP DATABASE okapi_modules;\""

echo "Existing roles: "
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"SELECT rolname FROM pg_roles;\""

DROP_ROLE diku_mod_permissions 
DROP_ROLE diku_mod_permissions;
DROP_ROLE diku_mod_template_engine;
DROP_ROLE diku_mod_email;
DROP_ROLE diku_mod_notify;
DROP_ROLE diku_mod_users;
DROP_ROLE diku_mod_authtoken;
DROP_ROLE diku_mod_pubsub;
DROP_ROLE diku_mod_login;
DROP_ROLE diku_mod_feesfines;
DROP_ROLE diku_mod_event_config;
DROP_ROLE diku_mod_patron_blocks;
DROP_ROLE diku_mod_finance_storage;
DROP_ROLE diku_mod_circulation_storage;
DROP_ROLE diku_mod_orders_storage;
DROP_ROLE diku_mod_configuration;
DROP_ROLE diku_mod_inventory_storage;
DROP_ROLE diku_mod_password_validator;
DROP_ROLE diku_mod_marc_storage;
DROP_ROLE diku_mod_eusage_reports;
DROP_ROLE diku_mod_harvester_admin;

echo "Remaining roles:"
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"SELECT rolname FROM pg_roles;\""
