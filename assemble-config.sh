# Injects `moduleConfigs`  from ../shared/module-configs.json into the provided project configuration file.
# OBS: Overwrites the file.
template="$1"
moduleConfigs="$2"

MOD_CONF=$(jq -r '.moduleConfigs' "$moduleConfigs")

project=$(jq -r --argjson modConf "$MOD_CONF" -r '.moduleConfigs=$modConf' "$template")

echo "$project" > "$template"
