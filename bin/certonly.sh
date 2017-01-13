#!/bin/sh
set -e
# This runs only the first time, as a standalone server
echo Asking for certificates for the first time
$CERTONLY || $CONTINUE_ON_CERTONLY_FAILURE
