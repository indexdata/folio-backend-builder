SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export workdir=$SCRIPT_DIR

clear

./tenants/create-tenants.sh
./modules/register-deploy-assign-modules.sh
#./modules/register-deploy-assign-inventory-storage-and-update.sh

$workdir/folio-users/create-diku_admin.sh

$workdir/auth-locking.sh

echo `date`
