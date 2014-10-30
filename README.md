# HTTPS Proxy

Use [HAProxy][] to create a HTTPS proxy.

## Usage

Just link it to any container listening on port 80:

    docker run -d -p 80:80 -p 443:443 --link other-web:www yajo/https-proxy

Then navigate to `https://localhost` and add security exception.

### When the main container uses other port

The proxy will use `${WWW_PORT_${PORT}_TCP_ADDR}` as origin, so run it as:

    docker run -e PORT=8080 --link other-web:www yajo/https-proxy

### When you have a real certificate

You can put your `key.pem` and `cert.pem` files under `/etc/pki/tls/private/`
in a subimage. Your `Dockerfile` will be similar to:

    FROM yajo/https-proxy
    MAINTAINER you@example.com
    ADD key.pem /etc/pki/tls/private/
    ADD cert.pem /etc/pki/tls/private/

You can also supply them with environment variables:

    docker run -e KEY="$(cat key.pem)" -e CERT="$(cat cert.pem)" --link other-web:www yajo/https-proxy

## Feedback

Please send any feedback (issues, questions) to the [issue tracker][].

[HAProxy]: http://www.haproxy.org/
[issue tracker]: https://bitbucket.org/yajo/docker-https-proxy/issues
