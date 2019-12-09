#!/bin/sh

#iptables -I FORWARD -j ACCEPT (?)





############################################################
#           Start wireguard
############################################################
ip link del dev wg0 2>/dev/null || true
ip link add dev wg0 type wireguard
wg set wg0 listen-port 1194 private-key /root/privatekey
ip address add 10.0.0.1/24 dev wg0
ip link set up dev wg0


############################################################
#          Configure the authorized wireguard clients
############################################################
#wg set wg0 peer PEER_B_PUBLIC_KEY persistent-keepalive 25 allowed-ips 10.0.0.0/24 

############################################################
#           We add 7 gre interfaces for the 7 clients
############################################################
ip link add tap1 type gretap remote 10.0.0.2 local 10.0.0.1
ip link set up dev tap1
brctl addif br-lan tap1
ip link set tap1 mtu 15000

ip link add tap2 type gretap remote 10.0.0.3 local 10.0.0.1
ip link set up dev tap2
brctl addif br-lan tap2
ip link set tap2 mtu 15000

ip link add tap3 type gretap remote 10.0.0.4 local 10.0.0.1
ip link set up dev tap3
brctl addif br-lan tap3
ip link set tap3 mtu 15000

ip link add tap4 type gretap remote 10.0.0.5 local 10.0.0.1
ip link set up dev tap4
brctl addif br-lan tap4
ip link set tap4 mtu 15000

ip link add tap5 type gretap remote 10.0.0.6 local 10.0.0.1
ip link set up dev tap5
brctl addif br-lan tap5
ip link set tap5 mtu 15000

ip link add tap6 type gretap remote 10.0.0.7 local 10.0.0.1
ip link set up dev tap6
brctl addif br-lan tap6
ip link set tap6 mtu 15000

ip link add tap7 type gretap remote 10.0.0.8 local 10.0.0.1
ip link set up dev tap7
brctl addif br-lan tap7
ip link set tap7 mtu 15000
