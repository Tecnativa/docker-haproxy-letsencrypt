#!/bin/sh
set -e
echo Generating /usr/local/etc/haproxy/haproxy.cfg
cat /usr/local/etc/haproxy/conf.d/*.cfg > /usr/local/etc/haproxy/haproxy.cfg
