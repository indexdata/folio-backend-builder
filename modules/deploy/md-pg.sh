mod=$1
gitdir=$2
host=$3
version=$4

jq --arg host $host -r '(.launchDescriptor.env[] | select(.name=="DB_HOST") | .value) |= $host' $gitdir/$mod/target/ModuleDescriptor.json
