# FOLIO installation scripts.

Scripts for installing a local FOLIO backend, built from directories of Git checkouts, and based on a project specific
installation file written in JSON.

Given the prerequisites described below, the scripts will configure a local Postgres database, and initialize and start
Okapi. Next, a JSON configuration file that lists the modules to install will be used for declaring, deploying and
enabling the modules with Okapi. The configuration also contains settings for tenants and users, though they are
currently required to be 'diku' and 'diku_admin' respectively. See [sample configuration](./modules/my-folio.json)

The order of operations of the main installation script is roughly:

* Create tenant diku
* Install basic modules for the user infrastructure
* Create user 'diku_admin' with credentials
* Install selected FOLIO modules for 'diku' with permissions to 'diku_admin'
* Lock down auth by enabling authtoken and users-bl for tenant diku

## Prerequisites

* Postgres installed and running.
* Kafka installed and running.
* Okapi checked out from folio-org at GitHub, together with all FOLIO modules to be installed.
* Okapi and FOLIO modules are built (`mvn install`), some perhaps dockerized.
* Postgres has a user 'okapi' and a database 'okapi' created (see instructions next).
* `curl` and `jq` will be needed for running the module installations scripts.

#### Create Okapi user in Postgres

```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

#### Initialize database

`java -Dport=8600 -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar initdatabase`

#### Start Okapi

`java -Dstorage=postgres -jar $FOLIO/okapi/okapi-core/target/okapi-core-fat.jar dev`

#### Or, use this script instead to both initialize the database and start Okapi

In root of this project, and assuming Okapi is checked out to `$HOME/folio` do

`export FOLIO=~/folio; ./okapi/init-db-start-okapi.sh`

## Install modules for tenant diku

To clean up the database schema first and start from scratch, do:

`./postgresdb/drop-and-recreate-okapi-modules-database.sh`

Then run the installation itself; pass in the project configuration JSON:

`./install-a-folio.sh modules/my-folio.json`

The configuration has settings for one or more JVMs and any given system could of course use other locations for Java
than this example, so those settings must be adapted. See the property `jvms`. It's possible that the selected modules
can be run with the default JVM on a system, making this setting obsolete in some cases. However, from time to time, the
JVM requirements for different FOLIO modules have diverged. The checkout directories (`checkoutRoots`) likewise must be
amended to fit the directory structure on the given development box.

### Checking the configuration

Optionally, the installation configuration can be (lightly) checked using:

`./modules/validate-config.sh modules/my-folio.json`

### Deselecting modules

Modules can be de-selected by removing the entry from `selectedModules`. The module configuration can be retained in the
config if desired.

A module can also be skipped by renaming the property `name`. Name it `skipped` instead for example:

```
{ "name": "mod-patron-blocks",           "version": "1.9.0-SNAPSHOT"},
{ "name": "mod-calendar",                "version": "2.4.3-SNAPSHOT"},
{ "name": "mod-notes",                   "version": "5.1.0-SNAPSHOT"},
{ "skipped": "mod-circulation",             "version": "23.6.0-SNAPSHOT"},
{ "skipped": "mod-inventory",               "version": "20.1.0-SNAPSHOT"}
```

## Install in one go

If Okapi is ready, and the JVM paths are checked, it should be possible to run the installation configuration like this:

```
cd ~/install-folio-backend ; clear; \
./postgresdb/drop-and-recreate-okapi-modules-database.sh;\
./modules/validate-config.sh modules/my-folio.json; read;\
./modules/install-a-folio.sh modules/my-folio.json
```

## Other uses for the config JSON

In `my-folio.json` there are settings for each module's remote Git repository. This is not used or required by the
installation scripts, so it can be left out. However, it might provide some convenience when upgrading a system across
the board.

Assuming the current arbitrarily chosen property name `githost` one could for example write a one-liner that will
generate the commands for a complete `git clone` and `mvn install` of all configured modules into a given directory:

```
jq -r '.moduleConfigs[] | 
"git clone --recurse-submodules " + .githost + "/"  + .name + ";
 cd " + .name + ";  
 mvn clean install -D skipTests ; 
 cd .." ' ../install-folio-backend/modules/my-folio.json  > clone-and-build.sh

```

If tagged released were used throughout - rather than snapshots as in `my-folio.json`, the script could easily be
extended to check out given tags after cloning. The script could of course also do git pulls across an existing
check-out directory of FOLIO modules.

The shown command doesn't account for diverging JVM requirements. The info needed to support that is in the JSON config,
but it's a bit trickier to get out.

## Could-Dos

#### Get rid of all static deployment descriptors

Some modules need environment variables beyond the standard Postgres and Kafka ones. For those modules, static
deployment descriptors are kept in the ./modules directory. They could preferably be included in the JSON config
instead. Examples of this are added to the my-folio.json config for pubsub and circulation.

#### Handle multiple tenants and users that could additionally be other than 'diku'

The script will only handle one tenant from the config and one user. Also, despite the tenant and user being
configurable, the installation script in its current form will only work with 'diku' and 'diku_admin'. Both issues would
be nice to resolve.

#### Only drop PG roles for modules that are being installed.

The script drop-pgdb-okapi_modules-and-roles.sh will drop any roles it knows of. I might just drop the currently
relevant roles. Not a big deal, i.e. if the role doesn't exist it will just skip it.

#### Simplify main installation script with some bash functions around curl requests

Perhaps.


