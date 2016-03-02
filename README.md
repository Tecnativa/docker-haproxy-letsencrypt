# HTTPS Proxy

Use [HAProxy][] to create a HTTPS proxy.

To understand settings in configuration files, see
[online manual](https://cbonte.github.io/haproxy-dconv/).

## Disclaimer about load balancing

This container uses HAProxy, but **it does not perform load balancing**.
It's just for adding an HTTPS layer to any HTTP container.

However, feel free to fork or subclass this image to do it, or just use other
container for load balancing and link it to this one to add HTTPS to it.

## Usage

Just link it to any container listening on port 80
(let's call it LC for Linked Container):

    docker run -d -p 80:80 -p 443:443 --link LC:www yajo/https-proxy

Then navigate to `https://localhost` and add security exception.

### When the LC exposes other port

The proxy will use `${WWW_PORT_${PORT}_TCP_ADDR}` as origin, so run it as:

    docker run -e PORT=8080 --link LC:www yajo/https-proxy

### When you have a real certificate

You can put your `key.pem` and `cert.pem` files under `/etc/ssl/private/`
in a subimage. Your `Dockerfile` will be similar to:

    FROM yajo/https-proxy
    MAINTAINER you@example.com
    ADD cert.pem key.pem /etc/ssl/private/

You can also supply them with environment variables:

    docker run -e KEY="$(cat key.pem)" -e CERT="$(cat cert.pem)" --link LC:www yajo/https-proxy

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
requests come in HTTP form), all requests will have this additional
header: `X-Forwarded-Proto: https`.

You can use that to make HTTPS (`https://example.com/other-page`)
redirections, or just use relative (`../other-page`) or protocol-agnostic
(`//example.com/other-page`) redirections and it will always work
anywhere (this is a good practice, BTW).

If you don't want this forced redirection (to maintain both HTTP and HTTPS
versions of your site), just expose port 80 from your LC and port 443
from the proxy.

## Feedback

Please send any feedback (issues, questions) to the [issue tracker][].

[HAProxy]: http://www.haproxy.org/
[issue tracker]: https://bitbucket.org/yajo/docker-https-proxy/issues
