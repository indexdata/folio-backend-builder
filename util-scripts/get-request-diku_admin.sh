host=$1
request=$2
echo request
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)
echo Token: $token
echo Host/request: $host/$request

curl -L -w -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://$host/$request
