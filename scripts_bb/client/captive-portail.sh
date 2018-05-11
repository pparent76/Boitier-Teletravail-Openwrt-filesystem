#!/bin/sh

killall openvpn
/etc/init.d/dnsmasq stop

iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80
iptables -D FORWARD -i br-lan -o br-wan -j DROP
iptables -D FORWARD -i br-lan -o wlan0 -j DROP   
iptables -t nat -I POSTROUTING -o wlan0 -j MASQUERADE
iptables -I FORWARD -j ACCEPT

#TODO we need to write dnsmasq conf so that it replies correct DNS.

/etc/init.d/dnsmasq start
echo "local">/tmp/bb/client/mode
