
The import script in this directory is a modified version of import.sh from mod-inventory-storage.

It's modified for the tenant used ('diku') and it applies the Okapi token since this one is run with authtoken module enabled.

However, the data samples are fetched from mod-inventory-storage

In other words: The import.sh script here can get out of synch with it's equivalent in mod-inventory-storage/sample-data/import.sh

For instance, in order to still be useful it should be updated as more data types are added to mod-inventory-storage.