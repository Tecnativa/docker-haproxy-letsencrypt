#!/bin/bash
cd /etc/ssl/private/

# Check if a combined certificate exists
if [ ! -f combined.pem ]; then
    # Check if it is splitted
    if [ ! -f key.pem -o ! -f cert.pem ]; then
        # Check if it is in the environment variables
        if [ -n "$KEY" -a -n "$CERT" ]; then
            echo "$KEY" > key.pem
            echo "$CERT" > cert.pem

        else
            # Create snakeoil certificate and key
            echo [DOCKER ALERT] No key+cert pair found. Generating a snakeoil \
                 one. Remember to use real ones for production. See README.

            openssl req -x509 -sha256 -newkey rsa:2048 -keyout key.pem \
                    -out cert.pem -days 365 -batch -nodes
        fi
    fi

    # Combine certificate and key
    cat cert.pem key.pem > combined.pem
fi

# Fall back to original entrypoint
exec /docker-entrypoint.sh "$@"
