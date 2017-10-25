# Creates user 'diku_admin'/'admin' with many admin permissions
workdir=$FOLIO/install-folio-backend/diku_admin

$workdir/POST-user.sh
$workdir/POST-credentials.sh
$workdir/POST-permissions.sh
