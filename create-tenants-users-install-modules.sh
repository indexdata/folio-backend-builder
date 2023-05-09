SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export workdir=$SCRIPT_DIR

clear

./tenants/create-tenants.sh

./modules/register-deploy-assign-modules.sh

$workdir/folio-users/create-diku_admin.sh

./modules/auth-locking.sh

echo `date`
