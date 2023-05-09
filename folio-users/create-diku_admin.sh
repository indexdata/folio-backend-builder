# Creates user 'diku_admin'/'admin' with many admin permissions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

$workdir/POST-user.sh diku diku_admin
echo User created; read
$workdir/POST-credentials.sh diku diku_admin
echo With credentials; read
$workdir/POST-permissions.sh diku diku_admin $workdir/diku_admin/permissions.json
echo Enter; read

