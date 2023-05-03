SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
tenant=$1
username=$2
permissionsFile=$3

echo POST permissions for user $username at $tenant
curl -H "X-Okapi-Tenant: ${tenant}" -H "Content-type: application/json" -X POST -d@$permissionsFile http://localhost:9130/perms/users