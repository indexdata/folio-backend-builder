# FOLIO back-end builder

Scripts for installing a local, single server, FOLIO backend, entirely built from local directories of Git checkouts. 

The installation script `install-folio.sh` is based on a given project specific installation file written in JSON.

The order of operations of the `install-folio.sh` is roughly:

* Create tenant diku
* Install basic modules for the user infrastructure
* Create user 'diku_admin' with credentials
* Install selected FOLIO modules for 'diku' with permissions to 'diku_admin'
* Lock down auth by enabling authtoken and users-bl for tenant diku

## Prerequisites for running `install-folio.sh`

Before the script can be run, following environment must be in place. There are helper scripts in this project for some of these tasks.

* Postgres installed and running.
* Kafka installed and running.
* Docker (if any modules should be deployed as Docker containers)
* Postgres has the user `okapi` and database `okapi` (instructions from Okapi guide below)
* Postgres has the user `folio_admin` and database `okapi_modules` (helper scripts in ./postgresdb)
* Okapi is checked out from folio-org at GitHub.
* All FOLIO modules to be installed are checked out from their respective source repositories, i.e. folio-org at GitHub.
* Okapi and FOLIO modules are built (`mvn install`), some perhaps dockerized.
* `curl` and `jq` will be needed for running the module installations scripts.

## Create the Postgres databases and database users and start Okapi

The following instructions for getting Okapi ready and running are much better described in the main Folio guides, especially in the Okapi README and Okapi guide, see for example

* [Okapi READE](https://github.com/folio-org/okapi/blob/master/README.md)
* [Compiling and running Okapi](https://github.com/folio-org/okapi/blob/master/doc/guide.md#compiling-and-running)
* [Okapi storage](https://github.com/folio-org/okapi/blob/master/doc/guide.md#storage)

What follows is thus the bare minimum extract from those guides for one way to get Okapi ready for the module installation script.

#### Create Okapi user and database in Postgres (once)

```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

#### Create super user folio_admin (once)

Creates the Postgres user that modules will use for creating their database schema in the `okapi_modules` database.

`./postgresdb/create-pg-superuser-folio-admin.sh`

#### Initialize Okapi database and start Okapi

Assuming Okapi is checked out to ~/folio, do:

`java -Dport=8600 -Dstorage=postgres -jar ~/folio/okapi/okapi-core/target/okapi-core-fat.jar initdatabase` (if needed/desired before start - see Okapi guide)

`java -Dstorage=postgres -jar ~/folio/okapi/okapi-core/target/okapi-core-fat.jar dev`

Alternatively use  `export FOLIO=~/folio; ./okapi/init-db-start-okapi.sh`  

#### Create the modules database, potentially removing previously installed modules first

`./postgresdb/create-pg-okapi_modules.sh`

or 

`./postgresdb/drop-and-recreate-okapi-modules-database.sh`


## Install all modules

Now run the installation script while passing in a selected project configuration JSON, for example:

`./install-folio.sh projects/simple-inventory.json`  for a minimal install

`./install-folio.sh projects/my-folio.json` for a larger - though by no means complete - FOLIO. It contains 20+ modules.


## The configuration file

The configuration files holds some basic information about the local environment, like the locations of check-out directories and JVMs as well as configurations for all modules to install.  

### Host dependent settings

#### Sample directory locations settings

```
    "checkoutRoots": [
        {
            "symbol": "GIT-FOLIO",
            "directory": "~/folio"
        },
        {
            "symbol": "GIT-OLE",
            "directory": "~/git-ole"
        },
        {
            "symbol": "GIT-ID",
            "directory": "~/gitprojects"
        },
        {
            "symbol": "GIT-NE",
            "directory": "~/gitne"
        }
    ]
```

#### Sample JVM settings

```
"jvms": [
        {
            "symbol": "JAVA11",
            "home": "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"
        },
        {
            "symbol": "JAVA17",
            "home": "/usr/lib/jvm/java-17-openjdk-amd64/bin/java"
        },
    ]
```
#### Environment variables
Many modules use one of a few standard sets of environment variables. The module configuration can reference one of them or supply a specific set of variables of its own. Here is a sample of standard sets:

```
"envVars": [
        {
            "symbol": "STANDARD-PG",
            "env": [
                { "name": "DB_HOST", "value": "localhost"},
                { "name": "DB_PORT", "value": 5432},
                { "name": "DB_USERNAME", "value": "folio_admin" },
                { "name": "DB_PASSWORD", "value": "folio_admin" },
                { "name": "DB_DATABASE", "value": "okapi_modules" }
            ]
        },
        {
            "symbol": "STANDARD-PG-KAFKA",
            "env": [
                { "name": "DB_HOST", "value": "localhost"},
                { "name": "DB_PORT", "value": 5432},
                { "name": "DB_USERNAME", "value": "folio_admin" },
                { "name": "DB_PASSWORD", "value": "folio_admin" },
                { "name": "DB_DATABASE", "value": "okapi_modules" },
                { "name": "KAFKA_HOST", "value": "localhost"},
                { "name": "KAFKA_PORT", "value": "9092" }
            ]
        },
        {
            "symbol": "NO-ENV-VARS",
            "env": []
        }
    ],
```

### Module configurations

With those basic system dependent settings defined, each module to install can be configured. For example: 

``` 
 { 
    "name": "mod-circulation-storage",     
    "checkedOutTo": "GIT-FOLIO",
    "githost": "https://github.com/folio-org",
    "requiredBy": [
        "mod-circulation",
        "mod-inventory",
        "mod-feesfines",
        "mod-template-engine"
    ],
    "deployment": {
        "method": "DD",
        "env": "STANDARD-PG",
        "jvm": "JAVA11",
        "pathToJar": "target/mod-circulation-storage-fat.jar"
    },
    "permissions": [
        "circulation-storage.all"
    ]
}
```
The properties `githost` and `requiredBy` are optional/informational. 

With these settings the installation script will find the module, create a deployment descriptor (unless deployment method is DOCKER), and deploy.

#### Method of deployment
For modules that are deployed using a deployment descriptor, the `deployment.method` should be "DD". Otherwise the install script will assume that the module descriptor has a launch descriptor, like is usually the case for Docker based deployment.

#### Finding the JAR
The path to the JAR must be provided, relative to the module's check out directory, using `checkedOutTo`, `name` and `pathToJar` 

#### Select a runtime JVM `deplayment.jvm`
The JVM to use must also be specified. The configuration has a section for assigning a short symbol to each JVM path, and that JVM is then referenced in the module config by that symbol. At the time of writing most projects can be deployed using Java 11, and in the sample JSON the symbol for that is "JAVA11". The path itself might very well have to be changed to match the system the script is running on.

#### Select or provide environment variables  
Finally, environment variables may have to be set. There are currently three predefined standard settings to choose from:

* Standard Postgres: `PG`  (see `mod-permissions` config in sample JSON)
* Standard Postgres and Kafka  `PG-KAFKA` (see `mod-users` in sample)
* No environment variables needed `NO-ENV-VARS` (see `mod-sender`)

A few modules have specific extra parameters though. For that the `deployment.env` property can be populated with the exact parameters the module needs. See `mod-pubsub` in the sample config. 

#### Setting permissions

In `permissions`, provide a list of permissions to assign to `diku_admin` for the module. 

### Checking the configuration

Optionally, the installation configuration can be (lightly) checked using:

`./configutils/validate-config.sh projects/my-folio.json`

(Creating a JSON schema for the configuration JSON is work-in-progress.)

### Selecting and deselecting modules

Modules to install must be listed in `selectedModules`

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

The `version` is informational and optional. It might eventually be used for flagging if a checked out version is not the specified version.

## Run the installation script.

It should be possible to run the installation configuration. In this sample command module databases and cleaned up and recreated before running the installation.

```
cd ~/folio-backend-builder ; clear; \
./postgresdb/drop-and-recreate-okapi-modules-database.sh;\
./configutils/validate-config.sh projects/my-folio.json; read;\
./install-folio.sh projects/my-folio.json
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
 cd .." ' ../folio-backend-builder/projects/my-folio.json  > clone-and-build.sh

```

If tagged released were used throughout - rather than snapshots as in `my-folio.json`, the script could easily be
extended to check out given tags after cloning. The script could of course also do git pulls across an existing
check-out directory of FOLIO modules.

The shown command doesn't account for diverging JVM requirements. The info needed to support that is in the JSON config,
but it's a bit trickier to get out.

## Could-Dos

#### Handle Docker deployment

Currently, the Postgres host env var `PG_HOST` can be changed from 'postgres' to the IP of localhost in the ModuleDescriptor for a Docker based deployment so that Postgres can be accessed from the container. There must be a better way? Anyways, obtaining that IP could be scripted (on Unix) with `hostname  -I | cut -f1 -d' '`

#### Improve validation of project configurations

I.e. mandatory fields and combination requirements. 

#### Handle multiple tenants and users that could additionally be other than 'diku'

The script will only handle one tenant from the config and one user. Also, despite the tenant and user being
configurable, the installation script in its current form will only work with 'diku' and 'diku_admin'. Both issues would
be nice to resolve.

#### Only drop PG roles for modules that are being installed.

The script drop-pgdb-okapi_modules-and-roles.sh will drop any roles it knows of. I might just drop the currently
relevant roles. Not a big deal, i.e. if the role doesn't exist it will just skip it.

#### Support for re-deploy

