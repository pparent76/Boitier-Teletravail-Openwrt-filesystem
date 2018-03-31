#!/bin/sh

iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80
iptables -t nat -I POSTROUTING -o wlan0 -j MASQUERADE
iptables -I FORWARD -j ACCEPT
