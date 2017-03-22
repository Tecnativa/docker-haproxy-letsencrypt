# HTTPS Proxy

[![](https://images.microbadger.com/badges/image/tecnativa/haproxy-letsencrypt.svg)](https://microbadger.com/images/tecnativa/haproxy-letsencrypt "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/tecnativa/haproxy-letsencrypt.svg)](https://microbadger.com/images/tecnativa/haproxy-letsencrypt "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/tecnativa/haproxy-letsencrypt:latest.svg)](https://microbadger.com/images/tecnativa/haproxy-letsencrypt:latest "Get your own commit badge on microbadger.com")

Use [HAProxy][] to create a HTTPS proxy with for [Let's Encrypt][].

To understand settings in configuration files, see
[online manual](https://cbonte.github.io/haproxy-dconv/).

## Disclaimer about load balancing

This container uses HAProxy, but **it does not perform load balancing**.
It's just for adding an HTTPS layer to any HTTP container.

However, feel free to fork or subclass this image to do it, or just use other
container for load balancing and link it to this one to add HTTPS to it.

## Disclaimer about certificates storage

You should store the `/etc/letsencrypt` volume contents somewhere persistent
and safe. It contains certificates and private keys, and those things **are
important**.

## How does it work?

It is based on the
[officially-supported HAProxy Alpine image](https://hub.docker.com/_/haproxy/)
with a
[hash-pinned](https://github.com/Tecnativa/docker-haproxy-letsencrypt/blob/master/certbot.txt)
install of the official ACME client supported by Let's Encrypt and the EFF:
[Certbot][], so it tries to stick to official recommendations as close as
possible.

Before booting HAProxy, it uses the provided configuration to get any missing
certificates from Let's Encrypt directly using
[Certbot's standalone `http-01`](https://certbot.eff.org/docs/using.html#standalone)
challenge implementation, directly on port 80.

After that, it combines the certificate chain with the private key to satisfy
[HAProxy's requirements](http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#5.1-crt)
and generates a
[`crt-list`](http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#crt-list)
file ready for HAProxy's taste.

Finally, it will boot up the server using with configuration from
`/etc/haproxy/*.cfg`.

## Skip the boring parts

If you understand the [Docker Compose file][], then all you need to do is to
open [`docker-compose.yaml`][], follow any instructions labeled with `XXX`, and
adapt that structure to your project.

## Usage and boring stuff

Just link it to any container listening on port 80
(let's call it LC for Linked Container):

    docker run -d -p 80:80 -p 443:443 --link LC:www tecnativa/haproxy-letsencrypt

Then navigate to `https://localhost` and add security exception.

### When the LC exposes other port

The proxy will use `www:$PORT` as origin, so run it as:

    docker run -e PORT=8080 --link LC:www yajo/https-proxy

### When you want custom error pages

This is preconfigured to use error pages from the examples. Just override the
corresponding error page found in `/usr/local/etc/haproxy/errors` in your
subimage:

    FROM yajo/https-proxy
    MAINTAINER you@example.com
    ADD 400.http 503.http /usr/local/etc/haproxy/errors/

### Automatic redirection of HTTP

This image will redirect all HTTP traffic to HTTPS, but this is a job that
**should** be handled by your LC in production to avoid this little overhead.

To help your LC know it is proxied (because it will seem to the LC like
requests come in HTTP form), all requests will have common additional headers
like `X-Forwarded-Proto: https` and
[other common ones](https://github.com/Tecnativa/docker-haproxy-letsencrypt/blob/master/conf/60-backend-main.cfg).

You can use that to make HTTPS (`https://example.com/other-page`)
redirections, or just use relative (`../other-page`) or protocol-agnostic
(`//example.com/other-page`) redirections and it will always work
anywhere (this is a good practice, BTW).

If you don't want this forced redirection (to maintain both HTTP and HTTPS
versions of your site), just expose port 80 from your LC and port 443
from the proxy.

### Automatic redirection of `www.example.com` to `example.com`

This container reduces redundancy by removing the `www.` prefix to any request.

You can do it the other way around with `-e WWW_PREFIX=FORCE`, or disable it
with `-e WWW_PREFIX=0`.

### Special modes

You can use the `MODE` environment variable to switch to some special modes by
setting it to any of these values:

#### `NORMAL` (default)

It simply adds its magic to redirect all HTTP(S) requests to the backend, as
explained above.

#### `ODOO`

It redirects all requests for `/longpolling` and its subdirs to
`www:$ODOO_LONGPOLLING_PORT` (`www:8072` by default).

Normally you combine this mode with `e PORT=8069`, and you must configure
correctly the workers parameter for the Odoo linked container. Check its docs
for that.

### Configuring [Certbot][]

You can override the template in `/usr/src/cli.ini` with the default options
that are going to be used. It gets environment variable-expanded in the
entrypoint. Use any
[configuration](https://certbot.eff.org/docs/using.html#configuration-file) you
want.

By default you should use these environment variables to make it work:

#### `STAGING`

Set it to `false` to start using the real Let's Encrypt CA. By default (`true`)
it uses the
[staging environment](https://letsencrypt.org/docs/staging-environment/).

#### `EMAIL`

Set your real email to interact with Let's Encrypt.

#### `DOMAINS`

Comma-separated list of domains you are serving with this container (and for
whom you want certificates).

Remember that if you are going to serve both `www.example.com` and
`example.com`, you have to ask for both.

#### `RSA_KEY_SIZE`

By default it is a bit higher than [Certbot][]'s default: `4096`.

### Using replacement hooks

Some configuration files have hooks, such as `# AFTER WWW HOOK`. Those strings
can be used as a replacement target in your subimage `Dockerfile` with `sed -i`
to inject some extra rules in those places.

## Feedback

Please send any feedback (issues, questions) to the [issue tracker][].

[HAProxy]: http://www.haproxy.org/
[Certbot]: https://certbot.eff.org/docs/using.html#renewing-certificates
[Docker Compose file]: https://docs.docker.com/compose/compose-file/
[`docker-compose.yaml`]: https://github.com/Tecnativa/docker-haproxy-letsencrypt/blob/master/docker-compose.yaml
[Let's Encrypt]: https://letsencrypt.org/
[issue tracker]: https://github.com/Tecnativa/docker-haproxy-letsencrypt/issues
