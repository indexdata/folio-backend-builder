curl -w '\n' -X POST -D - \
    -H "Content-type: application/json" \
    -d '{
    "id": "north",
    "name": "Northern Lights",
    "description": "Second Tenant Institute"
  }' \
    http://localhost:9130/_/proxy/tenants