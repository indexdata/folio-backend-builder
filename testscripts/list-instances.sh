banner="Listing instances"

. $1

curl $protocol://$host/instance-storage/instances -H "X-Okapi-Tenant: $tenant" -H "X-Okapi-Token: $token" -H "Content-Type: application/json" -H "Accept: application/json"  
