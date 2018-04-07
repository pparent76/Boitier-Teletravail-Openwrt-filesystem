#!/bin/sh

mode=$(uci get bridgebox.general.mode)

/scripts_bb/wifi.sh
/etc/init.d/dnsmasq restart

if [ "$mode" = "server" ]; then
    /scripts_bb/server/startup-server.sh
fi
