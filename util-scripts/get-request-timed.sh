host=$1
request=$2

token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)

curl -w "@curl-format.txt"  -s -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token"  http://$host/$request

