echo "Logging into AWS SSO..."
if aws sso login; then
    echo "Starting port forwarding session..."
    aws ssm start-session \
        --target i-044a14fdab0f8ad29 \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters '{"host":["tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com"],"portNumber":["5432"],"localPortNumber":["5433"]}'
else
    echo "AWS SSO login failed"
    return 1
fi
