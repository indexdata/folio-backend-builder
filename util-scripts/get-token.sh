tenant=$1
username=$2
password=$3
protocol=$4
host=$5

curl -s -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: $tenant"  -d "{ \"username\": \"$username\", \"password\": \"$password\"}" $protocol://$host/authn/login | grep x-okapi-token | cut -d " " -f2 

