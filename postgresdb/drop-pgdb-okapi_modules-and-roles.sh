sudo -u postgres bash -c "PGPASSWORD=post psql -c \"DROP DATABASE okapi_modules;\""

sudo -u postgres bash -c "PGPASSWORD=post psql -c  \"
DROP ROLE IF EXISTS diku_mod_permissions;
DROP ROLE IF EXISTS diku_mod_template_engine;
DROP ROLE IF EXISTS diku_mod_email;
DROP ROLE IF EXISTS diku_mod_notify;
DROP ROLE IF EXISTS diku_mod_users;
DROP ROLE IF EXISTS diku_mod_authtoken;
DROP ROLE IF EXISTS diku_mod_pubsub;
DROP ROLE IF EXISTS diku_mod_login;
DROP ROLE IF EXISTS diku_mod_feesfines;
DROP ROLE IF EXISTS diku_mod_event_config;
DROP ROLE IF EXISTS diku_mod_patron_blocks;
DROP ROLE IF EXISTS diku_mod_finance_storage;
DROP ROLE IF EXISTS diku_mod_circulation_storage;
DROP ROLE IF EXISTS diku_mod_orders_storage;
DROP ROLE IF EXISTS diku_mod_configuration;
DROP ROLE IF EXISTS diku_mod_inventory_storage;
DROP ROLE IF EXISTS diku_mod_password_validator;
DROP ROLE IF EXISTS diku_mod_marc_storage;
DROP ROLE IF EXISTS diku_mod_eusage_reports;
DROP ROLE IF EXISTS diku_mod_shared_index;
DROP ROLE IF EXISTS north_mod_configuration;
DROP ROLE IF EXISTS diku_mod_harvester_admin;
DROP ROLE IF EXISTS north_mod_inventory_storage;
DROP ROLE IF EXISTS north_mod_password_validator;
DROP ROLE IF EXISTS north_mod_marc_storage; \""


