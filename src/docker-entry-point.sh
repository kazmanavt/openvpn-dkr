#!/bin/sh

. /env.sh

# fix mounting volume from FS
[ ! -f ${CFDIR}/up.sh ] && cp -a ${CFDIR}.std/up.sh ${CFDIR}/
[ ! -f ${CFDIR}/down.sh ] && cp -a ${CFDIR}.std/down.sh ${CFDIR}/


echo '########################################################'
echo '##########        Initializing PKI        ##############'
echo '########################################################'

[ ! -r ${PKI}/ca.crt ] && {
    easyrsa --batch init-pki
    easyrsa --batch build-ca nopass
}
[ ! -r ${PKI}/issued/server.crt ] || [ ! -r ${PKI}/private/server.key ] && {
    rm -f ${PKI}/issued/server.crt ${PKI}/private/server.key ${PKI}/reqs/server.req
    easyrsa --batch build-server-full server nopass
}
[ ! -r ${PKI}/dh.pem ] && easyrsa --batch gen-dh


echo '########################################################'
echo '##########   Initializing OpenVPN config  ##############'
echo '########################################################'

# Server configuration

[ ! -r ${CFDIR}/server.conf ] && cp /etc/openvpn.std/server.conf ${CFDIR}
[ -n "$LISTEN" ] && {
    sed -e "s/^;*local .*$/local $LISTEN/" -i ${CFDIR}/server.conf
} || {
    sed -e 's/^;*local .*$/;local a.b.c.d/' -i ${CFDIR}/server.conf
}
sed -e "s/^port .*$/port ${PORT}/" -i ${CFDIR}/server.conf
[[ $UDP == 1 ]] && {
    sed -e 's/^;*proto udp.*$/proto udp/' \
        -e 's/^;*proto tcp.*$/;proto tcp/' \
        -i ${CFDIR}/server.conf
} || {
    sed -e 's/^;*proto udp.*$/;proto udp/' \
        -e 's/^;*proto tcp.*$/proto tcp/' \
        -i ${CFDIR}/server.conf
}
[[ $BRIDGE == 1 ]] && {
    sed -e "s/^;*server-bridge .*$/server-bridge ${BRIDGE_OPTS}/" \
        -e 's/^;*server .*/;server x.y.z.1 n.m.a.sk/' \
        -e 's/^;*dev tun.*$/;dev tun/' \
        -e 's/^;*dev tap.*$/dev tap/' \
        -e '/push "route/d' \
        -i ${CFDIR}/server.conf
} || {
    sed -e 's/^;*server-bridge .*$/;server-bridge x.y.z.1 n.m.a.sk x.y.z.start x.y.z.end/' \
        -e "s/^;*server .*/server ${RANGE}/" \
        -e 's/^;*dev tun.*$/dev tun/' \
        -e 's/^;*dev tap.*$/;dev tap/' \
        -i ${CFDIR}/server.conf
    echo ${ROUTES} | \
        awk '{ n = split( $0, a, " *, *"); for(i = 1; i <= n; i++) {  print a[i];} }' | \
        while read R; do
            echo "-$R-"
            echo "push \"route $R\"" >> ${CFDIR}/server.conf
        done
}

# Client configuration

[ ! -r ${CFDIR}/client.conf ] && cp /etc/openvpn.std/client.conf ${CFDIR}
[ -n "$LISTEN" ] && {
    sed -e "s/^;*remote .*$/remote $LISTEN $PORT/" -i ${CFDIR}/client.conf
} || {
    sed -e 's/^;*remote .*$/;remote a.b.c.d port/' -i ${CFDIR}/client.conf
}
[[ $UDP == 1 ]] && {
    sed -e 's/^;*proto udp.*$/proto udp/' \
        -e 's/^;*proto tcp.*$/;proto tcp/' \
        -i ${CFDIR}/client.conf
} || {
    sed -e 's/^;*proto udp.*$/;proto udp/' \
        -e 's/^;*proto tcp.*$/proto tcp/' \
        -i ${CFDIR}/client.conf
}

echo "Starting OpenVPN server."

/usr/sbin/openvpn /etc/openvpn/server.conf