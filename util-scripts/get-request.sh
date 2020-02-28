
tenant=$1
username=$2
password=$3
protocol=$4
host=$5
request=$6
echo Tenant $tenant
echo Username $username
echo Protocol $protocol
echo Host $host
echo Request $request
token=$($FOLIO/install-folio-backend/util-scripts/get-token.sh $tenant $username $password $protocol $host)
echo Token: $token
url=$protocol://$host$request

echo URL: $url

curl -L  "${url}"  -H "x-okapi-tenant: ${tenant}" -H 'content-type: application/json' -H "x-okapi-token: ${token}"

