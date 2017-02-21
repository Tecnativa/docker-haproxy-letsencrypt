FROM haproxy:1.7-alpine
MAINTAINER Tecnativa <info@tecnativa.com>

ENTRYPOINT ["/prepare-entrypoint.sh"]
CMD haproxy -- /etc/haproxy/*.cfg
EXPOSE 80 443

# The port listening in `www` container
ENV PORT=80 \
    MODE=NORMAL \
    # Odoo mode special variables
    ODOO_LONGPOLLING_PORT=8072 \
    # Use `FORCE` or `REMOVE`
    WWW_PREFIX=REMOVE \
    # Use `false` to ask for real certs
    STAGING=true \
    # Use `true` to continue on cert fetch failure
    CONTINUE_ON_CERTONLY_FAILURE=false \
    # Fill your data here
    EMAIL=example@example.com \
    DOMAINS=example.com,example.org \
    RSA_KEY_SIZE=4096 \
    # Command to fetch certs at container boot
    CERTONLY="certbot certonly --http-01-port 80" \
    # Command to monthly renew certs
    RENEW="certbot certonly"

# Certbot (officially supported Let's Encrypt client)
# SEE https://github.com/certbot/certbot/pull/4032
COPY cli.ini certbot.txt /usr/src/
RUN apk add --no-cache --virtual .certbot-deps \
        py2-pip \
        dialog \
        augeas-libs \
        libffi \
        libssl1.0 \
        wget \
        ca-certificates \
        binutils
RUN apk add --no-cache --virtual .build-deps \
        python-dev \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
    && pip install --no-cache-dir --require-hashes -r /usr/src/certbot.txt \
    && apk del .build-deps

# Cron
RUN apk add --no-cache dcron
RUN ln -s /usr/local/bin/renew.sh /etc/periodic/monthly/renew

# Utils
RUN apk add --no-cache gettext socat
RUN mkdir -p /var/lib/haproxy && touch /var/lib/haproxy/server-state
COPY conf/* /etc/haproxy/
COPY prepare-entrypoint.sh /
COPY bin/* /usr/local/bin/

VOLUME /var/spool/cron/cronstamps /etc/letsencrypt

# Metadata
ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor=Tecnativa \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="https://github.com/Tecnativa/docker-haproxy-letsencrypt"
