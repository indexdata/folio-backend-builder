V_MOD_AUTHTOKEN="2.14.0-SNAPSHOT"
V_MOD_USERS_BL="7.6.0-SNAPSHOT"

JAVA_11=/usr/lib/jvm/java-11-openjdk-amd64/bin/java

#Locks down module access to authenticated users
echo Assign mod-authtoken to DIKU
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "mod-authtoken-'$V_MOD_AUTHTOKEN'"}' http://localhost:9130/_/proxy/tenants/diku/modules
#echo Enter; read

echo Assign mod-users-bl to DIKU
curl -w '\n' -D - -H "Content-type: application/json" -d '{"id": "mod-users-bl-'$V_MOD_USERS_BL'"}' http://localhost:9130/_/proxy/tenants/diku/modules
