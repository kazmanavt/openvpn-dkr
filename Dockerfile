FROM alpine:3.6

RUN apk add --update openvpn easy-rsa \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* \
    && cp -a /etc/openvpn /etc/openvpn.std \
    && ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin/easyrsa


# ADD vars /etc/openvpn/vars
# ADD src/docker-entry-point.sh /docker-entry-point.sh
# ADD src/env.sh /
ADD defconf/*.conf /etc/openvpn.std/
ADD defconf/vars /usr/share/easy-rsa/
ADD bin/docker-entry-point /usr/local/bin/

VOLUME [ /etc/openvpn ]
ENTRYPOINT [ "/usr/local/bin/docker-entry-point" ]
