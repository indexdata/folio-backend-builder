banner="Listing locations"

. $1

curl $protocol://$host/locations -H "X-Okapi-Tenant: $tenant" -H "X-Okapi-Token: $token" -H "Content-Type: application/json" -H "Accept: application/json"  
