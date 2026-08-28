#!/bin/bash
# Fetch the TipMaster DB password for a given environment and copy it to the clipboard.
# Usage: tm-db-get-password.sh <prd|prd-oo|stg>
#
# prd    — main production Postgres, tunnelled on localhost:5433
# prd-oo — OpticOdds production Postgres (separate RDS box), tunnelled on localhost:5434
# stg    — staging, password read from the checked-out env file
#
# The two prd targets are DIFFERENT databases on different hardware with
# different credentials; each RDS box manages its own master secret.

set -euo pipefail

BASTION="ec2-user@3.130.146.14"
BASTION_KEY="$HOME/.ssh/tm-bastion"
AWS_DEFAULT_REGION_TM="us-east-2"

copy_to_clipboard() {
    echo -n "$1" | xclip -selection clipboard
}

# Open an SSH tunnel to an RDS host through the bastion. A no-op if one is
# already listening on the port, so this is safe to re-run.
open_tunnel() {
    local local_port="$1" rds_host="$2"

    if ss -ltn 2>/dev/null | grep -q ":${local_port} "; then
        echo "Tunnel already up on localhost:${local_port}"
        return 0
    fi

    ssh -fN -i "$BASTION_KEY" \
        -L "${local_port}:${rds_host}:5432" \
        "$BASTION" 2>/dev/null || true
}

# Password for an RDS-managed master secret, resolved FROM THE INSTANCE rather
# than a hardcoded id: `rds!db-<uuid>` names are opaque and there is one per box,
# so asking the instance for its own secret arn is the only way that stays right
# when a box is replaced.
rds_master_password() {
    local instance_id="$1" secret_arn password

    secret_arn=$(AWS_REGION="$AWS_DEFAULT_REGION_TM" aws rds describe-db-instances \
        --db-instance-identifier "$instance_id" \
        --query 'DBInstances[0].MasterUserSecret.SecretArn' \
        --output text 2>/dev/null || true)

    if [[ -z "$secret_arn" || "$secret_arn" == "None" ]]; then
        echo "Error: ${instance_id} has no RDS-managed master secret (or no rds:DescribeDBInstances permission)" >&2
        return 1
    fi

    password=$(AWS_REGION="$AWS_DEFAULT_REGION_TM" aws secretsmanager get-secret-value \
        --secret-id "$secret_arn" \
        --query SecretString --output text | jq -r .password)

    if [[ -z "$password" || "$password" == "null" ]]; then
        echo "Error: could not retrieve the password for ${instance_id} from Secrets Manager" >&2
        return 1
    fi

    echo -n "$password"
}

ENV="${1:-}"

case "$ENV" in
    prd)
        open_tunnel 5433 tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com

        aws sso login

        # Kept as a literal: this is the long-standing prd secret, and pinning it
        # means a describe-instances failure cannot silently change which
        # database the password unlocks.
        DB_PASSWORD=$(AWS_REGION="$AWS_DEFAULT_REGION_TM" aws secretsmanager get-secret-value \
            --secret-id 'rds!db-63c263e4-a52a-4bd0-9aed-28bef7b293f0' \
            --query SecretString --output text | jq -r .password)

        if [[ -z "$DB_PASSWORD" || "$DB_PASSWORD" == "null" ]]; then
            echo "Error: could not retrieve prd DB_PASSWORD from Secrets Manager" >&2
            exit 1
        fi

        CONNECT_HINT="psql -h 127.0.0.1 -p 5433 -U postgres -d backend   (sslmode=disable)"
        ;;

    prd-oo)
        open_tunnel 5434 tm-prd-opticodds.clmokqmsk1un.us-east-2.rds.amazonaws.com

        aws sso login --use_device-code

        DB_PASSWORD=$(rds_master_password tm-prd-opticodds)

        # This box REQUIRES SSL — unlike the main prd box, which is plain TCP
        # behind the same bastion (verified 2026-08-27: pg_hba rejects an
        # unencrypted connection with "no pg_hba.conf entry ... no encryption").
        CONNECT_HINT="psql 'host=127.0.0.1 port=5434 user=postgres dbname=backend sslmode=require'"
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

        CONNECT_HINT=""
        ;;

    *)
        echo "Usage: $(basename "$0") <prd|prd-oo|stg>" >&2
        exit 1
        ;;
esac

copy_to_clipboard "$DB_PASSWORD"
echo "${ENV} DB_PASSWORD copied to clipboard"
# An `[[ ... ]] && echo` here would exit 1 under `set -e` whenever the hint is
# empty, i.e. every stg run.
if [[ -n "$CONNECT_HINT" ]]; then
    echo "$CONNECT_HINT"
fi
