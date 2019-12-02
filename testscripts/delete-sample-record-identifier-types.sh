host=$1
token=$($FOLIO/install-folio-backend/util-scripts/get-token-diku_admin.sh $host)
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/identifier-types/2117d011-f52b-4efe-ab97-f11d0a4b77e5
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/identifier-types/47a65482-f104-45e8-aead-1f12d70dcf32
curl -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $token" -X DELETE http://$host/identifier-types/9db07825-8035-4d9a-8a41-d59a5f1c337b