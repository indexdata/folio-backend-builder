sudo -u postgres bash -c "psql -c \"DROP DATABASE okapi_modules;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_permissions;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_users;\""
sudo -u postgres bash -c "psql -c \"DROP ROLE diku_mod_login;\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE okapi_modules WITH OWNER=folio_admin ENCODING 'UTF8' LC_CTYPE 'en_US.UTF-8' LC_COLLATE 'en_US.UTF-8' TEMPLATE 'template0';\""

