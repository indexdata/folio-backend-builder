SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export workdir=$SCRIPT_DIR

started=`date`

./tenants/create-tenants.sh

./modules/create-diku-admin-install-modules-v2.sh

./modules/auth-locking.sh

echo Started $started
echo Ended "  `date`"
