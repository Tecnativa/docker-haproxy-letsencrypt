#!/bin/sh
set -e
echo Generating /etc/letsencrypt/cli.ini
envsubst < /usr/src/cli.ini > /etc/letsencrypt/cli.ini
