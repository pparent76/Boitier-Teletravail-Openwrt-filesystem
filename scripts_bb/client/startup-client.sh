#!/bin/sh

echo "Pierre"
iptables -I INPUT -p tcp --dport 80 -i wlan0 -j DROP
iptables -I INPUT -p tcp --dport 443 -i wlan0 -j DROP
iptables -I INPUT -p tcp --dport 22 -i wlan0 -j DROP

iptables -I INPUT -p tcp --dport 80 -i eth0 -j DROP
iptables -I INPUT -p tcp --dport 443 -i eth0 -j DROP
iptables -I INPUT -p tcp --dport 22 -i eth0 -j DROP

iptables -I INPUT -p tcp --dport 80 -i br-wan -j DROP
iptables -I INPUT -p tcp --dport 443 -i br-wan -j DROP
iptables -I INPUT -p tcp --dport 22 -i br-wan -j DROP
