
echo "Creating database 'okapi_modules', owner 'folio_admin'"
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"CREATE DATABASE okapi_modules WITH OWNER=folio_admin ENCODING 'UTF8' LC_CTYPE 'en_US.UTF-8' LC_COLLATE 'en_US.UTF-8' TEMPLATE 'template0';\""
