#!/bin/sh

mode=$(uci get bridgebox.general.mode)

/scripts_bb/setup-tor.sh
/scripts_bb/wifi.sh
sleep 5;
/etc/init.d/dnsmasq start
/etc/init.d/dnsmasq enable

/scripts_bb/common-iptables.sh

if [ "$mode" = "server" ]; then
    /scripts_bb/server/startup-server.sh
fi

if [ "$mode" = "client" ]; then
    /scripts_bb/client/startup-client.sh
fi
