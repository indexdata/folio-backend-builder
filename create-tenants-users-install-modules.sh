SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export workdir=$SCRIPT_DIR

clear
started=`date`

./tenants/create-tenants.sh

./modules/create-diku-admin-install-modules.sh

./modules/auth-locking.sh

echo Started $started
echo Ended "  `date`"
