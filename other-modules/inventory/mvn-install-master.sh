echo Install mod-inventory-storage
cd $FOLIO/mod-inventory-storage
git checkout master
mvn clean install
echo Install mod-inventory
cd $FOLIO/mod-inventory
git checkout master
mvn clean install
echo Install mod-codex-mux
cd $FOLIO/mod-codex-mux
git checkout master
mvn clean install
echo Install mod-codex-inventory
cd $FOLIO/mod-codex-inventory
git checkout master
mvn clean install
echo Install mod-circulation-storage
cd $FOLIO/mod-circulation-storage
git checkout master
mvn clean install
echo Install mod-circulation
cd $FOLIO/mod-circulation
git checkout master
mvn clean install
echo Install mod-rtac
cd $FOLIO/mod-rtac
git checkout master
mvn clean install

ls -l $FOLIO/mod-inventory-storage/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-inventory/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-codex-mux/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-codex-inventory/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-circulation-storage/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-circulation/target/mod-*SNAPSHOT.jar
ls -l $FOLIO/mod-rtac/target/mod-*SNAPSHOT.jar


