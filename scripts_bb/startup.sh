#!/bin/sh

if [ ! -h "/usr/bin/torsocks" ]; then
ln -s /usr/local/bin/torsocks /usr/bin/torsocks
fi

if [ ! -e "/etc/openvpn/keys/client.crt" ]; then
/scripts_bb/make-keys.sh
fi

echo 990 > /proc/sys/vm/min_free_kbytes
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
