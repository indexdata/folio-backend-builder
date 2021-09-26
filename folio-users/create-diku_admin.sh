# Creates user 'diku_admin'/'admin' with many admin permissions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

$workdir/POST-user.sh diku diku_admin
$workdir/POST-credentials.sh diku diku_admin
$workdir/POST-permissions.sh diku diku_admin
