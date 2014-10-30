FROM yajo/haproxy

MAINTAINER yajo@openaliasbox.org

EXPOSE 80 443

# Proxy port 80 by default, but can be changed
ENV PORT 80

RUN yum -y install openssl

ADD 50-https.cfg /etc/haproxy/
