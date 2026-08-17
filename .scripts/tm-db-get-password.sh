#!/bin/bash
# Fetch the TipMaster DB password for a given environment and copy it to the clipboard.
# Usage: tm-db-get-password.sh <prd|stg>

set -euo pipefail

ENV="${1:-}"

copy_to_clipboard() {
    echo -n "$1" | xclip -selection clipboard
}

case "$ENV" in
    prd)
        # Open the SSH tunnel to the prod RDS bastion (no-op if already up)
        ssh -fN -i ~/.ssh/tm-bastion \
            -L 5433:tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com:5432 \
            ec2-user@3.130.146.14 2>/dev/null || true

        aws sso login

        DB_PASSWORD=$(AWS_REGION=us-east-2 aws secretsmanager get-secret-value \
            --secret-id 'rds!db-63c263e4-a52a-4bd0-9aed-28bef7b293f0' \
            --query SecretString --output text | jq -r .password)

        if [[ -z "$DB_PASSWORD" || "$DB_PASSWORD" == "null" ]]; then
            echo "Error: could not retrieve prd DB_PASSWORD from Secrets Manager" >&2
            exit 1
        fi
        ;;

    stg)
        ENV_FILE="$HOME/dev/work/exbetz-be-api/.env.staging.tipmaster"

        if [[ ! -f "$ENV_FILE" ]]; then
            echo "Error: File $ENV_FILE not found" >&2
            exit 1
        fi

        DB_PASSWORD=$(grep "^DB_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^["'\'']//' | sed 's/["'\'']$//')

        if [[ -z "$DB_PASSWORD" ]]; then
            echo "Error: DB_PASSWORD not found in $ENV_FILE" >&2
            exit 1
        fi
        ;;

    *)
        echo "Usage: $(basename "$0") <prd|stg>" >&2
        exit 1
        ;;
esac

copy_to_clipboard "$DB_PASSWORD"
echo "${ENV} DB_PASSWORD copied to clipboard"
