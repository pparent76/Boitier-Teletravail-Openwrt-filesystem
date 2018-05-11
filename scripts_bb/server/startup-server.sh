#!/bin/sh

#Accepte le ssh sur le réseau hot
iptables -I INPUT -j ACCEPT

lighttpd -f /etc/lighttpd/advertise.conf 

mkdir -p /tmp/bb/server/

sleep 7;

/scripts_bb/server/upnp.sh
/scripts_bb/server/stun.sh
/scripts_bb/server/advertise.sh


/scripts_bb/server/openvpn.sh

