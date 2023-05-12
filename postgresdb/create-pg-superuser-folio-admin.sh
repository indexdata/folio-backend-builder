echo "Creating user 'folio_admin' with superuser password."
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"CREATE USER folio_admin WITH SUPERUSER PASSWORD 'folio_admin';\""
