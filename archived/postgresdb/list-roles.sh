echo "Roles in PostgreSQL database:"
sudo -u postgres bash -c "PGPASSWORD=post psql -c \"SELECT rolname FROM pg_roles;\""
