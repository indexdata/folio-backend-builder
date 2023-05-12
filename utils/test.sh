source ../modules/json-config-reader.sh

CONF="../modules/folio-hebis-reminder-fees.json"

res=$(javaHome mod-notify "3.0.1-SNAPSHOT" ../modules/folio-hebis-reminder-fees.json)

echo "Res: $res"

DD_SCRIPT=$(deployScript mod-notify "3.0.1-SNAPSHOT" $CONF)
echo script [$DD_SCRIPT]

DD_SCRIPT=$(deployScript mod-feesfines "18.3.0-SNAPSHOT" $CONF)
echo script [$DD_SCRIPT]

installParameters mod-inventory-storage 26.1.0-SNAPSHOT $CONF
