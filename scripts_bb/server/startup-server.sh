#!/bin/sh

#Accepte le ssh sur le réseau hote.
iptables -I INPUT -j ACCEPT

#Lancement de dnsmasq en mode normal
echo "">/etc/dnsmasq.conf
/etc/init.d/dnsmasq restart

#Lancement de lighttpd pour l'advertisement
lighttpd -f /etc/lighttpd/advertise.conf 

#Manipulation de répertoires de droits.
mkdir -p /tmp/bb/server/
chown http /etc/server-codes

#cron
cp /etc/crontab-server /etc/crontabs/root
/etc/init.d/cron restart

sleep 2;

#Start openvpn
/scripts_bb/server/openvpn.sh

sleep 5;

#Handle port forwarding
/scripts_bb/server/handle-port-forwarding.sh


