#!/bin/sh

#Redirect everything to localhost (Captive portail like function)
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
iptables -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80

#Allow the web interface to be reachable from 2.2.2.2
ifconfig br-lan:0 2.2.2.2

#ebtables -t nat -I PREROUTING -p ipv4 --ip-dst 2.2.2.2 -j redirect  --redirect-target DROP

iptables -t nat -F PREROUTING
ebtables -t broute -A BROUTING -p ipv4 -i wlan1 --ip-dst 2.2.2.2 -j redirect --redirect-target DROP
ebtables -t broute -A BROUTING -p ipv4 -i eth1 --ip-dst 2.2.2.2 -j redirect --redirect-target DROP
iptables -I FORWARD -i eth0 -s 2.2.2.2 -j DROP

ip rule add fwmark 2 table 3
iptables -t mangle -I OUTPUT -s 2.2.2.2 -j MARK --set-mark 2
ip route add 0.0.0.0/0 dev br-lan table 3
 

# ebtables -t broute -A OUTPUT -p ipv4 -o tap0  --ip-src 2.2.2.2 -j redirect --redirect-target DROP
# ebtables -t broute -A OUTPUT  -p ipv4 -o wlan1  --ip-src 2.2.2.2 -j redirect --redirect-target ACCEPT
# ebtables -t broute -A OUTPUT  -p ipv4 -o eth1  --ip-src 2.2.2.2 -j redirect --redirect-target ACCEPT

#ebtables -t broute -A BROUTING -p ipv4 -i eth1 --ip-dst 2.2.2.2 -j redirect --redirect-target DROP

