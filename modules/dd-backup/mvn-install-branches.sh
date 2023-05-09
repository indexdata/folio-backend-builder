echo Install mod-inventory-storage
cd $FOLIO/mod-inventory-storage
mvn clean install
echo Install mod-inventory
cd $FOLIO/mod-inventory
mvn clean install
echo Install mod-codex-mux
cd $FOLIO/mod-codex-mux
mvn clean install
echo Install mod-codex-inventory
cd $FOLIO/mod-codex-inventory
mvn clean install
echo Install mod-circulation-storage
cd $FOLIO/mod-circulation-storage
mvn clean install
echo Install mod-circulation
cd $FOLIO/mod-circulation
mvn clean install
echo Install mod-rtac
cd $FOLIO/mod-rtac
mvn clean install

ls -l $FOLIO/mod-inventory-storage/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-inventory/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-codex-mux/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-codex-inventory/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-circulation-storage/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-circulation/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-rtac/target/mod-*SNAPSHOT.jar


