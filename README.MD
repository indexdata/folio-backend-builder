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

Before the script can be run, following environment must be in place. There are helper scripts in this project for some
of these tasks.

* Postgres installed and running.
* Kafka installed and running.
* Docker (if any modules should be deployed as Docker containers)
* Postgres has the user `okapi` and database `okapi` (see below)
* Postgres has the user `folio_admin` and database `okapi_modules` (see below)
* Okapi is checked out from folio-org at GitHub.
* All FOLIO modules to be installed are checked out, for example from folio-org at GitHub.
* Okapi and FOLIO modules are compiled. Some perhaps dockerized.
* Okapi is started (see below)

Apache Maven is required for compiling Okapi and modules.

For compiling and running the modules, multiple versions of Java may be required, depending on which modules are
included. At the time of writing JDK 8 should be phased out for most modules but JDK 11, 17, and 18 seems to be in play.
Most modules and Okapi will compile and run with JDK 11 (Okapi should still be able to run with JDK 8 actually).

Finally, `curl` and `jq` are required for the module installation script.

The main Folio guides describe much better the software versions required, how to set up the databases etc, and options
for building and starting Okapi.

* [Developer Setup](https://dev.folio.org/guides/developer-setup/)
* [Compiling and running Okapi](https://github.com/folio-org/okapi/blob/master/doc/guide.md#compiling-and-running)
* [Okapi storage](https://github.com/folio-org/okapi/blob/master/doc/guide.md#storage)
* [Okapi README](https://github.com/folio-org/okapi/blob/master/README.md)

For Kafka, perhaps see [Kafka quickstart](https://kafka.apache.org/quickstart)

## One time preparation of the database

### Create okapi user, okapi database, folio_admin user in Postgres (once)

Create okapi user

```
sudo -u postgres -i
createuser -P okapi   # When it asks for a password, enter okapi25
createdb -O okapi okapi
```

Create folio_admin user that modules will use for access to their database schema in the `okapi_modules` database.

```
sudo -u postgres -i
createuser -P --superuser folio_admin   # When it asks for a password, enter folio_admin
```

## Recurring preparations of the database and Okapi

Following actions can be performed before each new run of the modules installation script to clean up previous
installations.

#### Create the modules database, potentially removing previously installed modules first

Clean up first:
`./postgresdb/drop-pgdb-okapi_modules-and-roles.sh`

Create the database (again):
`./postgresdb/create-pg-okapi_modules.sh`

#### Initialize Okapi database and start Okapi

Assuming Okapi is checked out to (and installed in) ~/folio, do:

`java -Dport=8600 -Dstorage=postgres -jar ~/folio/okapi/okapi-core/target/okapi-core-fat.jar initdatabase`

`java -Dstorage=postgres -jar ~/folio/okapi/okapi-core/target/okapi-core-fat.jar dev`

#### A script for all of the above (clean up database, start Okapi)

`./clean-db-start-okapi.sh ~/folio`

## Install the modules

Now the installation script can be run; pass in a selected project configuration JSON, for example:

`./install-folio.sh projects/simple-inventory.json`

`./install-folio.sh projects/my-folio.json`

## Validate the configuration first?

It's possible to validate a given configuration file using [validate-config.sh](configutils/validate-config.sh)

The validation script will

* Check that all seven modules requried for the basic users and authentication handling are present in `basicModules`
* Check references between module configs and general settings internally in the config file
* Check for required properties
* Check that declared JVM paths and check-out directories exist in the file system.
* Check that basic as well as selected modules are checked out and compiled, with required artifacts present in the file
  system

`./configutils/validate-config.sh projects/my-folio.json`

## Configuration details

Here follows a walk-through of the different sections of the configuration file.

### Basic modules

The installation process requires at least seven basic modules to be installed. These are modules making it possible to
create users and give them credentials and permissions.

All other modules are optional, though often inter-dependencies will require one to be present for another to work.

The array `basicModules` holds the list of modules required by the installation script. Module `version` is optional and
only used for information. For example it can be used to flag that an installed version happens not to be the declared
version.

```
"basicModules" : [
        { "name": "mod-permissions",        "version": "6.4.0-SNAPSHOT" },
        { "name": "mod-users",              "version": "19.2.0-SNAPSHOT"},
        { "name": "mod-login",              "version": "7.10.0-SNAPSHOT"},
        { "name": "mod-password-validator", "version": "3.1.1-SNAPSHOT"},
        { "name": "mod-authtoken",          "version": "2.14.0-SNAPSHOT"},
        { "name": "mod-configuration",      "version": "5.9.2-SNAPSHOT"},
        { "name": "mod-users-bl",           "version": "7.6.0-SNAPSHOT"}
]
```

### System dependent settings

#### Sample directory locations settings

This sections defines, where on the file system, the modules to install are checked out. If using ~/folio for this there
is no need to change anything here.

The settings control both where the automatic git clone and mvn install script checks the projects out to, and where the
install-folio script picks them up.

If one wanted to create a new platform next to the main development environment, GIF-FOLIO might be changed to "~
/folio-tmp".

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
    }
]
```

#### Sample JVM settings

Most modules build and run with Java 11, a few require 17 or 18 to compile.

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
    {
        "symbol": "JAVA18",
        "home": "~/.jdks/openjdk-18.0.2.1"
    }
]
```

#### Standard environment variables

Many modules use one of a few standard sets of environment variables. The module configuration can reference one of them
or supply a specific set of variables of its own. Here is a sample of standard sets:

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
]
```

### Module configurations

With the above basic system dependent settings defined, each module to install can be configured. For example:

``` 
{ 
   "name": "mod-circulation-storage",     
   "checkedOutTo": "GIT-FOLIO",
   "gitHost": "https://github.com/folio-org",
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

The property `requiredBy` are is optional/informational. Keeping notes of interdependencies here can be convenient when
wanting to include or exclude modules from the package.

The property `gitHost` is used by the script that clones and compiles modules, but it will default
to `https://github.com/folio-org` so only need to be set for modules residing in other organisations.

#### Method of deployment

For modules that are deployed using a deployment descriptor, the `deployment.method` should be "DD". Otherwise the
install script will assume that the module descriptor has a launch descriptor, like is usually the case for Docker based
deployment.

#### Finding the JAR

The path to the JAR must be provided, relative to the module's check out directory, using `checkedOutTo`, `name`
and `pathToJar`

#### Select a runtime JVM

The JVM to use must also be specified in `deployment.jvm`. The property takes a short symbol to each JVM path, and that
JVM is then referenced in the module config by that symbol. At the time of writing most projects can be deployed using
Java 11, and in the sample JSON the symbol for that is "JAVA11". The path itself might very well have to be changed to
match the system the script is running on.

#### Select or provide environment variables

Finally, environment variables may have to be set. There are currently three predefined standard settings to choose
from:

* Standard Postgres: `PG`  (see `mod-permissions` config in sample JSON)
* Standard Postgres and Kafka  `PG-KAFKA` (see `mod-users` in sample)
* No environment variables needed `NO-ENV-VARS` (see `mod-sender`)

A few modules have specific extra parameters though. For that the `deployment.env` property can be populated with the
exact parameters the module needs. See `mod-pubsub` in the sample config.

#### Setting permissions

In `permissions`, provide a list of permissions to assign to `diku_admin` for the module.

### Selecting and deselecting modules

Modules to install must be listed in `selectedModules`

Modules can be de-selected by removing the entry from `selectedModules`. The module configuration can be retained in the
config if desired.

A module can also be skipped by renaming the property `name`. Name it `skipped` instead for example:

```
"selectedModules": [
    { "name": "mod-calendar",                "version": "2.4.3-SNAPSHOT"},
    { "name": "mod-notes",                   "version": "5.1.0-SNAPSHOT"},
    { "skipped": "mod-circulation",             "version": "23.6.0-SNAPSHOT"},
    { "skipped": "mod-inventory",               "version": "20.1.0-SNAPSHOT"}
]
```

The `version` is informational and optional. It might eventually be used for flagging if a checked out version is not
the specified version.

### Faking modules

A single interface dependency of a module can sometimes pull in a large dependency tree, or require modules that are
complicated to install, and where all the additional modules that must be installed to satisfy the dependency and the
dependency's dependencies are not necessarily needed
for the development project at hand. If they are truly not needed for the time being, it can be convenient to
intermittently fake some APIs, thereby keeping the overall footprint of the FOLIO instance manageable.

The property `fakeApis` can be used for that:

```
"fakeApis": {
    "provides": [
        {
            "id": "source-storage-records",
            "version": "3.0"
        },
        {
            "id": "instance-authority-links",
            "version": "2.0"
        }
    ]
}
```

This will prompt the installation of a module called `mod-fake-1.0.0`, which will ostensibly provide the listed
interfaces. It probably goes without saying that some cautiousness is warranted with this feature activated.

## Git cloning and Maven installing modules.

The script `clone-and-compile.sh` can be run on a configuration file to check out all the basic and selected modules
from Git, and compile (mvn install) them.

For example, create an empty directory, like ~/folio-modules. Define the check-out directories in the configuration file
to point to that base directory (see `clone-and-compile-demo.json`).

Then run

`./clone-and-compile.sh  projects/clone-and-compile-demo.json`

The script should tell what it's planning to do and ask for yes or no to continue.

When complete, the configuration can be checked with

`./configutils/validate-config.sh   projects/clone-and-compile-demo.json`

The clone and compile script can be pointed to an existing directory with module check-outs in it already. If a given
module check-out directory already exists, the script will not `git clone` that module, and if the directory contains
the build directory, `/target`, the script will not `mvn install`.

This also means that a clone-and-compile job can be resumed after an interruption, or it can add new modules to the
directory later without touching the existing ones.

## All-in-one

In separate windows: Start Kafka

```
.[kafka-install]/bin/zookeeper-server-start.sh config/zookeeper.properties`
.[kafka-install]/bin/kafka-server-start.sh config/server.properties` 
```   

In a separate window: Clean up past installations from the database and start Okapi

```
./clean-db-start-okapi.sh ~/folio    # <- use actual location of the Okapi checkout directory
```

Then, create the target directory for the module check-outs, and, in `/.../folio-backend-builder`, run the
clone-compile, validate, and install scripts:

```
# Create empty directory `~/folio-modules`

mkdir ~/folio-modules

# Clone the selected modules from git and compile them 

./clone-and-compile.sh   projects/clone-and-compile-demo.json

# Run the validations and take a moment to check results

./configutils/validate-config.sh projects/clone-and-compile-demo.json
printf "Press Enter " ; read

# Install the modules to Okapi

./install-folio.sh projects/clone-and-compile-demo.json
```

It should now be possible to log in as `diku_admin/admin` and GET some instances from `/instance-storage/instances`.

## Could-Dos

#### Schema for the configuration JSONs

#### Handle multiple tenants and users that could additionally be other than 'diku'

The script will only handle one tenant from the config and one user. Also, despite the tenant and user being
configurable, the installation script in its current form will only work with 'diku' and 'diku_admin'. Both issues would
be nice to resolve.

#### Only drop PG roles for modules that are being installed.

The script drop-pgdb-okapi_modules-and-roles.sh will drop any roles it knows of. I might just drop the currently
relevant roles. Not a big deal, i.e. if the role doesn't exist it will just skip it.

#### Script for easy re-deploy

