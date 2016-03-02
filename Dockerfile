FROM haproxy
MAINTAINER Jairo Llopis <yajo.sk8@gmail.com>

CMD ["/usr/local/sbin/launch.sh"]
EXPOSE 80 443

# Proxy port 80 by default, but can be changed
ENV PORT 80

RUN apt-get update && apt-get -y install openssl && apt-get clean &&\
    useradd --create-home --home-dir /var/lib/haproxy haproxy &&\
    chmod go= /var/lib/haproxy

ADD *.cfg /usr/local/etc/haproxy/
ADD *.sh /usr/local/sbin/
