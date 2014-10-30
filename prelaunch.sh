#!/usr/bin/bash

# Allow to use a custom port
export SERVER="$(eval "echo \$WWW_PORT_${PORT}_TCP_ADDR")"

previous="$(pwd)"
cd /etc/pki/tls/private/

# Check if a combined certificate exists
if [ ! -f combined.pem ]; then
    # Check if it is splitted
    if [ ! -f key.pem ] || [ ! -f cert.pem ]; then
        # Check if it is in the environment variables
        if [ "$KEY" != "" ] && [ "$CERT" != "" ]; then
            echo "$KEY" > key.pem
            echo "$CERT" > cert.pem

        else
            # Create snakeoil certificate and key
            echo [DOCKER ALERT] No key+cert pair found. Generating a snakeoil \
                 one. Remember to use real ones for production. See README.

            openssl req -x509 -sha256 -newkey rsa:2048 -keyout key.pem \
                    -out cert.pem -days 365
        fi
    fi

    # Combine certificate and key
    cat cert.pem key.pem > combined.pem
fi

cd "$previous"
