source ./json-config-reader.sh

selectedModules ../projects/my-folio.json

permissions mod-inventory-storage "26.1.0-SNAPSHOT" ../projects/my-folio.json

installParameters mod-inventory-storage "26.1.0-SNAPSHOT" ../projects/my-folio.json

installParameters mod-inventory-storage "26.2.0-SNAPSHOT" ../projects/my-folio.json


users  ../projects/my-folio.json

credentials ../projects/my-folio.json

tenants ../projects/my-folio.json

moduleVersionByName  "mod-authtoken" ../projects/my-folio.json

javaHome mod-inventory-storage "26.1.0-SNAPSHOT" ../projects/my-folio.json

echo dep:
dd1=$(deploymentDescriptor mod-circulation "23.6.0-SNAPSHOT" ../projects/my-folio.json)
echo $dd1

dd2=$(deploymentDescriptor mod-inventory-storage "26.1.0-SNAPSHOT" ../projects/my-folio.json)
echo $dd2

dd3=$(deploymentDescriptor mod-shared-index-muted-apis "1.0-SNAPSHOT" ../projects/my-folio.json)
echo $dd3

dd4=$(deploymentDescriptor mod-inventory "20.1.0-SNAPSHOT" ../projects/my-folio.json)
echo $dd4

dd5=$(deploymentDescriptor mod-event-config "2.6.0-SNAPSHOT" ../projects/my-folio.json)
echo $dd5
if [[ -z $dd5 ]]; then
  echo mod-event-config gave no dd
fi
