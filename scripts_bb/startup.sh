#!/bin/sh

/etc/init.d/uhttpd stop
/etc/init.d/uhttpd disable

if [ ! -h "/usr/bin/torsocks" ]; then
ln -s /usr/local/bin/torsocks /usr/bin/torsocks
fi

if [ ! -e "/root/pubkey" ]; then
/scripts_bb/make-keys.sh
fi

if [ ! -e "/etc/passwd-configured" ]; then
    echo -e "UcOuLdDoIt4Me\nUcOuLdDoIt4Me" | (passwd root)
    password=$(openssl rand -base64 14 | sed "s/=//g")
    echo "$password#Default password">/etc/server-codes
    touch /etc/passwd-configured
fi

echo 990 > /proc/sys/vm/min_free_kbytes
mode=$(uci get bridgebox.general.mode)

/scripts_bb/setup-tor.sh
/scripts_bb/wifi.sh
sleep 1;
mkdir -p /tmp/bb/internet/
echo "KO">/tmp/bb/internet/internet
/scripts_bb/check_internet/check-internet.sh &
sleep 4;
/etc/init.d/dnsmasq start
/etc/init.d/dnsmasq enable

/scripts_bb/common-iptables.sh

if [ "$mode" = "server" ]; then
    /scripts_bb/server/startup-server.sh
fi

if [ "$mode" = "client" ]; then
    /scripts_bb/client/startup-client.sh
fi
