SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export workdir=$SCRIPT_DIR
CONF=$1

if [[ -z "$CONF" ]]; then
  echo "Please provide JSON config file listing and configuring modules to be install:  ./create-tenants-users-install-modules.sh myconf.json"
  exit
fi

started=`date`

./modules/create-diku-admin-install-modules.sh $CONF

./modules/auth-locking.sh

echo Started $started
echo Ended "  `date`"
