#!/bin/sh

mkdir -p /tmp/bb/server/
/scripts_bb/server/upnp.sh
/scripts_bb/server/openvpn.sh

iptables -I INPUT -j ACCEPT
