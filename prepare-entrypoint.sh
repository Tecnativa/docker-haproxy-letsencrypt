#!/bin/sh
set -e
expand-certbot-ini.sh
certonly.sh
update-crt-list.sh
merge-conf.sh
echo Activating cron daemon
crond
echo Executing: $@
exec /docker-entrypoint.sh "$@"
