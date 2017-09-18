FROM alpine:3.6

RUN apk add --update openvpn easy-rsa \
    && cp -a /etc/openvpn /etc/openvpn.std

VOLUME [ /etc/openvpn ]

# ADD vars /etc/openvpn/vars
# ADD src/docker-entry-point.sh /docker-entry-point.sh
# ADD src/env.sh /
ADD src/*.sh /
ADD src/easyrsa /usr/local/bin/easyrsa
# ADD server.conf ${CFDIR}.std/server.conf
# ADD client.conf ${CFDIR}.std/client.conf
ADD defconf/*.conf /etc/openvpn.std/
ADD defconf/vars /usr/share/easy-rsa/

ENV PORT=1194 UDP=1 \
    BRIDGE=0 BRIDGE_OPTS="10.22.0.11 255.255.255.0 10.22.0.178 10.22.0.201" \
            RANGE="10.128.0.0 255.192.0.0" ROUTES="192.168.1.0 255.255.255.0"

ENTRYPOINT /docker-entry-point.sh
