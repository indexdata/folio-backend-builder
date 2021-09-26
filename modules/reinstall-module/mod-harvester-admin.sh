curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/diku/modules/mod-harvester-admin-0.1.0-SNAPSHOT
curl -X DELETE -D - -w '\n' http://localhost:9130/_/proxy/tenants/north/modules/mod-harvester-admin-0.1.0-SNAPSHOT

sleep 2
curl -X DELETE -D - -w '\n' http://localhost:9130/_/discovery/modules/mod-harvester-admin-0.1.0-SNAPSHOT

sleep 2
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @../harvester/DeploymentDescriptor-mod-harvester-admin.json http://localhost:9130/_/discovery/modules

sleep 2
curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @/home/ne/gitprojects/mod-harvester-admin/target/TenantModuleDescriptor-template.json http://localhost:9130/_/proxy/tenants/diku/modules

curl -w '\n' -D -    -X POST -H "Content-type: application/json" -d @/home/ne/gitprojects/mod-harvester-admin/target/TenantModuleDescriptor-template.json http://localhost:9130/_/proxy/tenants/north/modules

date
