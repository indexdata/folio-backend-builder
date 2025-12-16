# FOLIO back-end builder

Scripts for installing a local, single server, FOLIO backend, entirely built from Git checkouts of modules in local directories.

## Prerequisites 

* Apache Maven is required for compiling Okapi and modules.
* Docker is required for creating the basic infrastructure -- Postgres, Kafka, and ElasticSearch -- as well as for running individual modules as Docker containers if preferred. (Postgres and Kafka can alternatively be installed in the host rather than using the provided Docker container specification). 
* Various versions of Java may be required for running the modules, depending on which modules are
included and what version they are currently at. At the time of writing JDK 8 should be phased out for most modules but JDK 11, 17, and 18 seems to be in play.
Most modules and Okapi will compile and run with JDK 11 (Okapi should still be able to run with JDK 8 actually).
* The module installation script requires `curl` and `jq` to function.


## Check-out and install a FOLIO instance
This paragraph describes everything required to check out, build, install and run a small FOLIO instance. Following paragraphs will go into details of the individual parts of the process.

The project configuration used, clone-and-compile-demo.json, assumes certain JVMs for building and running modules to be present at configured file system locations. If the given Java versions resides somewhere else, the jvms section of clone-and-compile-demo.json should be modified accordingly.    

```
# Check out and compile Okapi, for example in directory HOME/folio

git clone --recurse-submodules https://github.com/folio-org/okapi
cd okapi
mvn clean install -D skipTests 

# Create directory `folio-demo` in HOME

mkdir ~/folio-demo

# Clone the selected modules from git and compile them 

./clone-and-compile-modules.sh   projects/clone-and-compile-demo.json

# Run the validations and take a moment to check results

./validate-config.sh projects/clone-and-compile-demo.json
printf "Press Enter " ; read

# Start op FOLIO with select modules

# This will start Okapi and required infrastructure services and then install the selected modules to Okapi. 
" By default the script expects Okapi to be found in HOME/folio/okapi. If Okapi is to run from another location, 
# the path can be specified with option `-o <path>` 

./startup-project.sh -o ~/folio projects/clone-and-compile-demo.json

```

It should now be possible to log in as `diku_admin/admin` and GET some instances from `/instance-storage/instances`.

## The check-out, build, install, and run process in more details. 

### Initialize infrastructure and start Okapi

Before modules can be installed, the basic infrastructure and Okapi must be up and running.

The script [start-folio-back-end](folio-service/start.sh) takes care of both, by starting a Docker container with Postgres and Kafka and then start Okapi.

### Install FOLIO modules

Now the installation script can be run using a select FOLIO project file; pass in the project configuration JSON, like this:

`./install-modules.sh projects/my-folio.json`

#### What install-modules.sh does

* Creates tenant diku
* Installs basic modules for handling users
* Creates user 'diku_admin' with credentials
* Installs selected FOLIO modules for 'diku' with permissions to 'diku_admin'
* Locks down auth by enabling authtoken and users-bl for tenant diku

### Validate the configuration first?

It's possible to validate a given configuration file using [validate-config.sh](validate-config.sh)

The validation script will

* Check that all seven modules required for the basic users and authentication handling are present in `basicModules`
* Check references between module configs and general settings internally in the config file
* Check for required properties
* Check that declared JVM paths and check-out directories exist in the file system.
* Check that basic as well as selected modules are checked out and compiled, with required artifacts present in the file
  system

`./validate-config.sh projects/my-folio.json`

### Configuration details

The project configuration consists of 10 sections that are described in more detail in the following paragraphs. 

| Property               | Purpose                                                                                  | Character                                                                             |
|------------------------|------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| sourceDirectory        | Main directory where the FOLIO modules are checked out to, for example "~/folio-modules" | Mandatory. To be set as desired for the local file system                             | 
| selectedModules        | List of modules to include in the installation                                           | Mandatory. To be set as desired for the current project                               |  
| alternativeDirectories | List of other directories containing modules                                             | Optional. To be set in case some modules should reside outside of the main directory. | 
| jvms                   | Paths to JDKs for compiling and/or running modules                                       | Mandatory. Depends on the local Java installations.                                   |
| fakeApis               | List of interfaces that should be faked to reduce the installation footprint             | Optional. Depends on the needs of the current project.                                |
| basicModules           | List of seven modules that are always needed for the installation                        | Mandatory. Samples here can be used. No changes needed.                               |
| moduleConfigs          | Configurations for, at least, all selected and basic modules                             | Mandatory. Samples here could be used as is, possibly with more modules added.        |
| tenants                | Array of one tenant definition, 'diku'                                                   | Mandatory. Samples here can be used. No changes needed.                               |
| users                  | Array of one user definition 'diku_admin'                                                | Mandatory. Samples here can be used. No changes needed.                               |
| envVars                | Standard sets of environment variables that will suffice for deployment of most modules  | Optional but very convenient. Samples here can be used.                               | 

So the essential configuration properties to check are 'sourceDirectory', 'selectedModules' and 'jvms'. 

#### Selecting modules

The installation process requires at least seven basic modules to be installed. These are modules making it possible to
create users and give them credentials and permissions.

All other modules are optional, though often interdependencies will require one to be present for another to work.

The array `basicModules` holds the list of modules required by the installation script. Module `version` is optional and
only used for information. For example, it can be used to flag that an installed version happens not to be the declared
version.

```
"basicModules" : [
        { "name": "mod-permissions",        "version": "6.4.0-SNAPSHOT" },
        { "name": "mod-users",              "version": "19.2.0-SNAPSHOT" },
        { "name": "mod-login",              "version": "7.10.0-SNAPSHOT" },
        { "name": "mod-password-validator", "version": "3.1.1-SNAPSHOT" },
        { "name": "mod-authtoken",          "version": "2.14.0-SNAPSHOT" },
        { "name": "mod-configuration",      "version": "5.9.2-SNAPSHOT" },
        { "name": "mod-users-bl",           "version": "7.6.0-SNAPSHOT" }
]
```

On top of that, any number of optional modules can be added:

```
"selectedModules": [
        { "name": "mod-inventory-storage",    "version": "26.1.0-SNAPSHOT" },
        { "name": "mod-pubsub",               "version": "2.10.0-SNAPSHOT" },
        { "name": "mod-circulation-storage",  "version": "16.1.0-SNAPSHOT" }, 
        { "name": "mod-event-config",         "version": "2.6.0-SNAPSHOT" },      
]
```

The `version` property is optional. It's potentially used for flagging if a checked out version
diverged from the specified version.

#### System dependent settings

##### Source directories

The configuration must define the source directory, or directories, where the modules are checked out.

The modules will be installed from the directory specified in `sourceDirectory` - in the example below under `/folio` in
the home directory.

Alternative locations can be defined for individual modules by a symbol that then must be defined
in `alternativeDirectories`, for example:

```
"selectedModules": [
        { "name": "mod-inventory-storage",    "version": "26.1.0-SNAPSHOT" },
        { "name": "mod-pubsub",               "version": "2.10.0-SNAPSHOT", "sourceDirectory": "TMP" },
        { "name": "mod-circulation-storage",  "version": "16.1.0-SNAPSHOT" }, 
        { "name": "mod-event-config",         "version": "2.6.0-SNAPSHOT" },      
        { "name": "my-module-1",              "version": "0.0.1-SNAPSHOT",  "sourceDirectory": "MY-GIT" }
        { "name": "my-module-2",              "version": "0.0.1-SNAPSHOT",  "sourceDirectory": "MY-GIT" } 
],
"sourceDirectory": "~/folio",
"alternativeDirectories": [
  {
    "symbol": "TMP",
    "directory": "~/tmp-folio"
  },
  { 
    "symbol": "MY-GIT",
    "directory": "~/gitprojects"
  }  
]
```

The scripts will not create these root directories, they must be created beforehand. The scripts should flag if the
specified directories don't exist.

##### Sample JVM settings

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

##### Standard environment variables

Many modules use one of a few standard sets of environment variables. The module configuration can reference one of them
or supply a specific set of variables of its own. Here is a sample of standard sets:

```
"envVars": [
    {
        "symbol": "STANDARD-PG",
        "env": [
            { "name": "DB_HOST", "value": "localhost" },
            { "name": "DB_PORT", "value": 5432},
            { "name": "DB_USERNAME", "value": "folio_admin" },
            { "name": "DB_PASSWORD", "value": "folio_admin" },
            { "name": "DB_DATABASE", "value": "okapi_modules" }
        ]
    },
    {
        "symbol": "STANDARD-PG-KAFKA",
        "env": [
            { "name": "DB_HOST", "value": "localhost" },
            { "name": "DB_PORT", "value": 5432},
            { "name": "DB_USERNAME", "value": "folio_admin" },
            { "name": "DB_PASSWORD", "value": "folio_admin" },
            { "name": "DB_DATABASE", "value": "okapi_modules" },
            { "name": "KAFKA_HOST", "value": "localhost" },
            { "name": "KAFKA_PORT", "value": "9092" }
        ]
    },
    {
        "symbol": "NO-ENV-VARS",
        "env": []
    }
]
```

#### Module configurations

With the above basic system dependent settings defined, each module to install can be configured. For example:

``` 
{ 
   "name": "mod-circulation-storage",     
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

The property `requiredBy` is optional/informational. Keeping notes of interdependencies here can be convenient when
wanting to include or exclude modules from the package.

#### Specifying Git repositories

If using the script in this tool that clones modules from GitHub, then modules are by default cloned
from https://github.com/folio-org.

If a module resides in another git repository, it can be specified in the module config:

``` 
{ 
   "name": "mod-my-module",     
   "gitHost": "https://github.com/my-organisation"
   "deployment": {
       "method": "DD",
       "env": "STANDARD-PG",
       "jvm": "JAVA11",
       "pathToJar": "target/mod-my-module-fat.jar"
   },
   "permissions": [
       "my-module.all"
   ]
}
```

It's also possible to override the default in the modules listing, for example if a module is temporarily forked
from `folio-org` to another organization

```
"selectedModules": [
    { "name": "mod-inventory",  "repo": "https://github.com/my-organisation" }
    { "name": "mod-inventory-storage" },
    { "name": "mod-pubsub" },
    { "name": "mod-circulation-storage" }, 
]
```

In other words, the Git repository will be "https://github.com/folio-org", unless this is overridden by `gitHost` in the module
configuration, unless this is overridden by `repo` in the modules listing.

##### Method of deployment

For modules that are deployed using a deployment descriptor, the `deployment.method` should be "DD". Otherwise, the
installation script will assume that the module descriptor has a launch descriptor, like is usually the case for Docker
based
deployment.

##### Select a runtime JVM

The JVM to use must also be specified in `deployment.jvm`. The property takes a short symbol to each JVM path, and that
JVM is then referenced in the module config by that symbol. At the time of writing most projects can be deployed using
Java 11, and in the sample JSON the symbol for that is "JAVA11". The path itself might very well have to be changed to
match the system the script is running on.

##### Select or provide environment variables

Finally, environment variables may have to be set. There are currently three predefined standard settings to choose
from:

* Standard Postgres: `PG`  (see `mod-permissions` config in sample JSON)
* Standard Postgres and Kafka  `PG-KAFKA` (see `mod-users` in sample)
* No environment variables needed `NO-ENV-VARS` (see `mod-sender`)

A few modules have specific extra parameters though. For that the `deployment.env` property can be populated with the
exact parameters the module needs. See `mod-pubsub` in the sample config.

##### Setting permissions

In `permissions`, provide a list of permissions to assign to `diku_admin` for the module.

#### Faking modules

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

### Git cloning and Maven installing modules.

The script [clone-and-compile-modules.sh](clone-and-compile-modules.sh) can be run on a configuration file to check out (clone) all the basic and selected modules
from Git, and compile (mvn install) them.

For example, create an empty directory, like ~/folio-modules. Define the source directories in the configuration file
to point to that base directory (see `clone-and-compile-demo.json`).

Then run

`./clone-and-compile-modules.sh  projects/clone-and-compile-demo.json`

The script should tell what it's planning to do and ask for yes or no to continue.

When complete, the configuration can be checked with

`./validate-config.sh   projects/clone-and-compile-demo.json`

The clone and compile script can be pointed to an existing directory with module check-outs in it already. If a given
module source directory already exists, the script will not `git clone` that module, and if the directory contains
the build directory, `/target`, the script will not `mvn install`.

This also means that a clone-and-compile job can be resumed after an interruption, or it can add new modules to the
directory later without touching the existing ones.



## Could-Dos

#### Schema for the configuration JSONs

#### Handle multiple tenants and users that could additionally be other than 'diku'

The script will only handle one tenant from the config and one user. Also, despite the tenant and user being
configurable, the installation script in its current form will only work with 'diku' and 'diku_admin'. Both issues would
be nice to resolve.



