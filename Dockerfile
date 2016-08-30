FROM haproxy
MAINTAINER Jairo Llopis <yajo.sk8@gmail.com>

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD haproxy -- /usr/local/etc/haproxy/*.cfg
EXPOSE 80 443
ENV PORT 80

RUN apt-get update && apt-get -y install openssl && apt-get clean &&\
    useradd --create-home --home-dir /var/lib/haproxy haproxy &&\
    chmod go= /var/lib/haproxy

ADD *.cfg /usr/local/etc/haproxy/
ADD *.sh /usr/local/sbin/
