token=$(curl -s -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: diku"  -d "{ \"username\": \"diku_admin\", \"password\": \"admin\"}" http://$1/authn/login | grep x-okapi-token | cut -d " " -f2); 

curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" http://$1/perms/users?query=\(userId%3D%221ad737b0-d847-11e6-bf26-cec0c932ce01%22\)


