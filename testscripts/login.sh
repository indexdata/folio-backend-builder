echo $banner
echo " at:    [$host]"
echo

# Get password
echo -n "Enter password for [$username] to continue, otherwise hit Enter to cancel: "
read -s password

if [ -z $password ]; then
  echo
  echo
  echo " Cancelled"
  echo
  exit 1
fi

token=$(curl -s -X POST -D - -H "Content-type: application/json" -H "X-Okapi-Tenant: $tenant"  -d "{ \"username\": \"$username\", \"password\": \"$password\"}" "$protocol://$host/authn/login" | grep x-okapi-token | tr -d '\r' | cut -d " " -f2)

