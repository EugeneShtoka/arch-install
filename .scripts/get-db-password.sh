#!/bin/bash

ENV_FILE="$HOME/dev/work/exbetz-be-api/.env.staging.tipmaster"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: File $ENV_FILE not found"
    exit 1
fi

DB_PASSWORD=$(grep "^DB_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^["'\'']//' | sed 's/["'\'']$//')

if [[ -z "$DB_PASSWORD" ]]; then
    echo "Error: DB_PASSWORD not found in $ENV_FILE"
    exit 1
fi

echo -n "$DB_PASSWORD" | xclip -selection clipboard
echo "DB_PASSWORD copied to clipboard"