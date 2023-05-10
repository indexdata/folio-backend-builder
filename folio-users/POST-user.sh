SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
tenant=$1
username=$2

echo POST $username to $tenant
curl -H "X-Okapi-Tenant: ${tenant}" -H "Content-type: application/json" -d@$workdir/$username/user.json http://localhost:9130/users