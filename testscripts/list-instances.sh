tenant=$1
username=$2
password=$3
protocol=$4
host=$5

token=$($FOLIO/install-folio-backend/util-scripts/get-token.sh $tenant $username $password http $host)
echo token: ${token}
echo tenant: $tenant
echo username: $username
echo password: $password
echo protocol: $protocol
echo host: $host
echo "TEST: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsInVzZXJfaWQiOiIwMTA4RTgxNC02RUNDLTRDNTAtQTE2Mi0yREFCNkNCNEM3RTgiLCJpYXQiOjE1NzAxOTc2MTAsInRlbmFudCI6InJlc2hhcmUifQ.p6mz-n5med8MTzFxlPyh98NaeK9vzlz2vfdeDp2Ld58 TEST"
echo "TEST: $token TEST"
echo "TEST: ${username} TEST"
curl -v $protocol://$host/instance-storage/instances -H "X-Okapi-Tenant: $tenant" -H "X-Okapi-Token: $token" -H "Content-Type: application/json" -H "Accept: application/json"  
