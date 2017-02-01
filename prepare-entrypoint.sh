#!/bin/sh
set -e
if [ "$STAGING" == true ]; then
    export STAGING_FLAG="staging = true"
fi
expand-certbot-ini.sh
certonly.sh
update-crt-list.sh
echo Activating cron daemon
crond
echo Executing: $@
exec /docker-entrypoint.sh "$@"
