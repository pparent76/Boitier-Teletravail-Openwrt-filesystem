#!/bin/sh

mode=$(uci get bridgebox.general.mode)

/scripts_bb/wifi.sh
sleep 5;
/etc/init.d/dnsmasq start
/etc/init.d/dnsmasq enable

iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80

if [ "$mode" = "server" ]; then
    /scripts_bb/server/startup-server.sh
fi

if [ "$mode" = "client" ]; then
    /scripts_bb/server/startup-client.sh
fi
