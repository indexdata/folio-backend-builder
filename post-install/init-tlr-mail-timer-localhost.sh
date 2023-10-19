. ~/curlio/login/diku@localhost.sh 
. ~/curlio/post-record.sh configurations/entries tlrconfig.json
. ~/curlio/s/post-record.sh smtp-configuration mail-config.json > /dev/null 
curl -XPATCH -d@reminders-timer-every-2-minutes.json http://localhost:9130/_/proxy/tenants/diku/timers/mod-circulation_12

