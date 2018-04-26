#!/bin/sh

#Redirect everything to localhost (Captive portail like function)
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80

#Allow the web interface to be reachable from 1.1.1.1
ifconfig br-lan:0 1.1.1.1

#ebtables -t nat -I PREROUTING -p ipv4 --ip-dst 1.1.1.1 -j redirect  --redirect-target DROP

iptables -t nat -F PREROUTING
ebtables -t broute -A BROUTING -p ipv4 -i wlan1 --ip-dst 1.1.1.1 -j redirect --redirect-target DROP

#ebtables -t broute -A BROUTING -p ipv4  --ip-src 1.1.1.1 -j redirect --redirect-target DROP
#ebtables -t broute -A BROUTING -p ipv4 -i eth1 --ip-dst 1.1.1.1 -j redirect --redirect-target DROP

