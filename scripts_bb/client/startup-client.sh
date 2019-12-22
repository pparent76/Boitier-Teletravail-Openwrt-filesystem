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

iptables -I INPUT -p udp --dport 68 -m string --algo kmp --hex-string '|04000000053b0400000006|' -j LOG --log-prefix "APPAIRE-NOW"

#########################################
#Lancement des scripts d'appairage
#########################################
aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )
if [ "$aserverid" = "" ]|| [ "$aserverpubkey" = "" ]|| [ "$avpnaddress" = "" ]; then
    /scripts_bb/client/appaire-deamon.sh &
fi



#cron
cp /etc/crontab-client /etc/crontabs/root
/etc/init.d/cron restart


autostart=$(uci get bridgebox.advanced.clientautostart)
if [ "$autostart" = "1" ]; then
    /scripts_bb/client/autostart-entreprise.sh
else
    sleep 10
    /etc/init.d/dnsmasq restart
fi

/scripts_bb/client/keepalive-captiveportal.sh &

