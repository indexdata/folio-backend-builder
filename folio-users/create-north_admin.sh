# Creates user 'north_admin'/'admin' with many admin permissions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

$workdir/POST-user.sh north north_admin
$workdir/POST-credentials.sh north north_admin
$workdir/POST-permissions.sh north north_admin
