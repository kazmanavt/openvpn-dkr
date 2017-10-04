FROM alpine:3.6

RUN apk add --update openvpn easy-rsa \
    && cp -a /etc/openvpn /etc/openvpn.std \
    && ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin/easyrsa

VOLUME [ /etc/openvpn ]

# ADD vars /etc/openvpn/vars
# ADD src/docker-entry-point.sh /docker-entry-point.sh
# ADD src/env.sh /
ADD bin/docker-entry-point /usr/local/bin/
# ADD server.conf ${CFDIR}.std/server.conf
# ADD client.conf ${CFDIR}.std/client.conf
# ADD defconf/*.conf /etc/openvpn.std/
ADD defconf/vars /usr/share/easy-rsa/

ENTRYPOINT [ "/usr/local/bin/docker-entry-point" ]
