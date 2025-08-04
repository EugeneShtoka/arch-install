#!/bin/zsh

# Database tunnel script - connects to tipmaster-prd via SSM port forwarding

set -e # Exit on any error

# Configuration
TARGET_INSTANCE="i-044a14fdab0f8ad29"
RDS_HOST="tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com"
REMOTE_PORT="5432"
LOCAL_PORT="5433"

echo "Logging into AWS SSO..."

aws ssm start-session --target i-044a14fdab0f8ad29 --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com"],"portNumber":["5432"],"localPortNumber":["5433"]}'
if aws sso login; then
    echo "AWS SSO login successful"
    echo "Starting port forwarding session..."
    echo "Tunneling ${RDS_HOST}:${REMOTE_PORT} -> localhost:${LOCAL_PORT}"

    AWS_REGION=us-east-2 aws ssm start-session \
        --target "${TARGET_INSTANCE}" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"${RDS_HOST}\"],\"portNumber\":[\"${REMOTE_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}"
else
    echo "AWS SSO login failed"
    exit 1
fi
