#!/bin/sh
echo Reloading HAProxy
set -x
# SEE http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#4.2-load-server-state-from-file
echo show servers state | socat /var/lib/haproxy/stats - > /var/lib/haproxy/server-state
# SEE https://github.com/docker-library/docs/tree/master/haproxy#reloading-config
killall -s HUP haproxy-systemd-wrapper || true
