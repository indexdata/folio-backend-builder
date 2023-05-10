SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
username=$1

echo PUT permissions for user $username
curl -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -X PUT -d@$workdir/$username/permissions.json http://localhost:9130/perms/users/8d55ce02-472d-4649-a441-1ac16534564a