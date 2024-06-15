#!/bin/bash

CONFIG_PATH="/data/options.json"
N8N_PATH="/data/n8n"
CUSTOM_EXTENSIONS_PATH="/custom"

mkdir -p "${N8N_PATH}/.n8n/.cache"

#####################
## USER PARAMETERS ##
#####################

# REQUIRED

# Extract the values from env_vars_list
values=$(jq -r '.env_vars_list | .[]' "$CONFIG_PATH")

# Convert the values to an array
IFS=$'\n' read -r -d '' -a array <<< "$values"

# Export keys and values
for element in "${array[@]}"
do
    key="${element%%:*}"
    value="${element#*:}"
    value=$(echo "$value" | xargs) # Remove leading and trailing whitespace
    export "$key"="$value"
    echo "exported ${key}=${value}"
done
    
export N8N_BASIC_AUTH_ACTIVE="$(jq --raw-output '.auth // empty' $CONFIG_PATH)"
export N8N_BASIC_AUTH_USER="$(jq --raw-output '.auth_username // empty' $CONFIG_PATH)"
export N8N_BASIC_AUTH_PASSWORD="$(jq --raw-output '.auth_password // empty' $CONFIG_PATH)"
export GENERIC_TIMEZONE="$(jq --raw-output '.timezone // empty' $CONFIG_PATH)"
export N8N_PROTOCOL="$(jq --raw-output '.protocol // empty' $CONFIG_PATH)"
export N8N_SSL_CERT="/ssl/$(jq --raw-output '.certfile // empty' $CONFIG_PATH)"
export N8N_SSL_KEY="/ssl/$(jq --raw-output '.keyfile // empty' $CONFIG_PATH)"
export N8N_CMD_LINE="$(jq --raw-output '.cmd_line_args // empty' $CONFIG_PATH)"
export N8N_USER_FOLDER="${N8N_PATH}"
export N8N_CUSTOM_EXTENSIONS="${CUSTOM_EXTENSIONS_PATH}/node_modules/n8n-nodes-puppeteer-extended"

if [ -z "${N8N_BASIC_AUTH_USER}" ] || [ -z "${N8N_BASIC_AUTH_ACTIVE}" ]; then
    export N8N_BASIC_AUTH_ACTIVE=false
    unset N8N_BASIC_AUTH_USER
    unset N8N_BASIC_AUTH_PASSWORD
fi

###########
## MAIN  ##
###########

exec n8n start ${N8N_CMD_LINE}
