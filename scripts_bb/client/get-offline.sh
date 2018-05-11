#!/bin/sh

/etc/init.d/openvpn stop
killall openvpn

iptables -t nat -D POSTROUTING -o wlan0 -j MASQUERADE
iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80
iptables -D FORWARD -i br-lan -o br-wan -j DROP
iptables -D FORWARD -i br-lan -o wlan0 -j DROP 

#TODO we need to write dnsmasq conf so that it allways reply the same IP to DNS requests.

/etc/init.d/dnsmasq start
echo "offline">/tmp/bb/client/mode
