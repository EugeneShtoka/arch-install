#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh
echo 'Insert item name, login, password, url'
bw get template item | jq --arg name "$1" --arg username "$2" --arg password "$3" --arg url "$4" '.name=$name | .notes=null | .login.username=$username | .login.password=$password | .uris=[{uri: $url}]' | bw encode | bw create item