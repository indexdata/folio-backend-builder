SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workdir=$SCRIPT_DIR
tenant=$1
username=$2

echo POST credentials for user $username at $tenant

curl -v -H "X-Okapi-Tenant: ${tenant}" -H "Content-type: application/json" -X POST -d@$workdir/$username/credentials.json http://localhost:9130/authn/credentials
echo Enter; read
