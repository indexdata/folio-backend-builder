curl -w '\n' -X POST -D - \
    -H "Content-type: application/json" \
    -d '{
    "id": "diku",
    "name": "Datalogisk Institut",
    "description": "Danish Library Technology Institute"
  }' \
    http://localhost:9130/_/proxy/tenants