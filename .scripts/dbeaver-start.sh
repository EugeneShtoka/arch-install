#!/bin/zsh

pkill cloud-sql-proxy
cloud-sql-proxy swapp-v1-1564402864804:us-central1:swapp-postgres-db -p 5433 -c /usr/share/credentials/swapp-v1-1564402864804.json &
dbeaver
