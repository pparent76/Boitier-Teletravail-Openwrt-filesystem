#!/bin/sh

rmmod gpio_button_hotplug

ifconfig br-lan 192.168.8.2


#Accepte le ssh sur le réseau hote.
iptables -I INPUT -j ACCEPT

#Lancement de dnsmasq en mode normal
echo "address=/#/2.2.2.2">/etc/dnsmasq.conf
/etc/init.d/dnsmasq restart

#Lancement de lighttpd pour l'advertisement
lighttpd -f /etc/lighttpd/advertise.conf 

#Lancement de lighttpd pour l'appairage
iptables -I INPUT -p tcp --dport 55943 -j DROP
iptables -I INPUT -i br-lan -p tcp --dport 55943 -j ACCEPT
lighttpd -f /etc/lighttpd/appaire.conf

date +%s | sha256sum | head -c 42 > /advertise/challenge
chmod 777 /advertise/challenge

date +%s | sha256sum | head -c 42 > /appaire/challenge
chmod 777 /appaire/challenge

#Manipulation de répertoires de droits.
mkdir -p /tmp/bb/server/
usermod http -u 7894
chown http /etc/server-codes
chown http /etc/desappaire

#cron
cp /etc/crontab-server /etc/crontabs/root
/etc/init.d/cron restart

sleep 2;

#Start vpn
/scripts_bb/server/vpn.sh

sleep 5;

#Handle port forwarding
/scripts_bb/server/handle-port-forwarding.sh


