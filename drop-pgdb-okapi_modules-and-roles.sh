sudo -u postgres bash -c "psql -c \"DROP DATABASE okapi_modules;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_permissions;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_users;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_login;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_notify;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_configuration;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_event_config;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_sender;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_template_engine;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_inventory_storage;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_circulation_storage;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_password_validator;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_source_record_storage;\""
