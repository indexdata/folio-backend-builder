SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR

$workdir/create-tenant-diku.sh
#$workdir/create-tenant-north.sh

