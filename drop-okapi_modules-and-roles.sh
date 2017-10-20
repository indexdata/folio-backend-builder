sudo -u postgres bash -c "psql -c \"DROP DATABASE okapi_modules;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_permissions;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_users;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_login;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_configuration;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_inventory_storage;\""

