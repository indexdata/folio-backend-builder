SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
tenant=$1
username=$2

echo POST permissions for user $username at $tenant
curl -H "X-Okapi-Tenant: ${tenant}" -H "Content-type: application/json" -X POST -d@$workdir/$username/permissions.json http://localhost:9130/perms/users