#!/bin/sh

mkdir -p /tmp/bb/client
/scripts_bb/client/get-offline.sh 

chown http /etc/client-code-history

echo "Pierre"
iptables -I INPUT -p udp -i br-wan -j ACCEPT

iptables -I INPUT -p tcp --dport 80 -i wlan0 -j DROP
iptables -I INPUT -p tcp --dport 443 -i wlan0 -j DROP
iptables -I INPUT -p tcp --dport 22 -i wlan0 -j DROP

iptables -I INPUT -p tcp --dport 80 -i eth0 -j DROP
iptables -I INPUT -p tcp --dport 443 -i eth0 -j DROP
iptables -I INPUT -p tcp --dport 22 -i eth0 -j DROP

iptables -I INPUT -p tcp --dport 80 -i br-wan -j DROP
iptables -I INPUT -p tcp --dport 443 -i br-wan -j DROP
iptables -I INPUT -p tcp --dport 22 -i br-wan -j DROP

#cron
cp /etc/crontab-client /etc/crontabs/root
/etc/init.d/cron restart


autostart=$(uci get bridgebox.advanced.clientautostart)
if [ "$autostart" = "1" ]; then
    /scripts_bb/client/autostart-entreprise.sh
fi
