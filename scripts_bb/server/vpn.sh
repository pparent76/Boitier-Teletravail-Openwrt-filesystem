#!/bin/sh

#iptables -I FORWARD -j ACCEPT (?)





############################################################
#           Start wireguard
############################################################
ip link del dev wg0 2>/dev/null || true
ip link add dev wg0 type wireguard
wg set wg0 listen-port 1194 private-key /root/privatekey
ip address add 10.0.0.1/24 dev wg0
ip link set wg0 mtu 15000
ip link set up dev wg0


############################################################
#          Configure the authorized wireguard clients
############################################################

while IFS='' read -r line || [[ -n "$line" ]]; do
 if [ "$line" != "" ]; then 
    clefl=$(echo "$line" | tr '#' '\n' | head -n 2 | tail -n 1 | tr '\n' ' ' | sed "s/ //g")  
    # TODO Restrict authorized IP
    wg set wg0 peer $clefl allowed-ips 10.0.0.0/24 
  fi
done < /etc/server-codes

############################################################
#   For security reasons only allow gre to go throug wg0
############################################################
iptables -I OUPUT -d 10.0.0.0/24  -p 47  -j DROP
iptables -I OUPUT -d 10.0.0.0/24  -p 47 -o wg0  -j ACCEPT

############################################################
#           We add 7 gre interfaces for the 7 clients
############################################################
ip link add tap1 type gretap remote 10.0.0.2 local 10.0.0.1
ip link set up dev tap1
brctl addif br-wan tap1
ip link set tap1 mtu 15000

ip link add tap2 type gretap remote 10.0.0.3 local 10.0.0.1
ip link set up dev tap2
brctl addif br-wan tap2
ip link set tap2 mtu 15000

ip link add tap3 type gretap remote 10.0.0.4 local 10.0.0.1
ip link set up dev tap3
brctl addif br-wan tap3
ip link set tap3 mtu 15000

ip link add tap4 type gretap remote 10.0.0.5 local 10.0.0.1
ip link set up dev tap4
brctl addif br-wan tap4
ip link set tap4 mtu 15000

ip link add tap5 type gretap remote 10.0.0.6 local 10.0.0.1
ip link set up dev tap5
brctl addif br-wan tap5
ip link set tap5 mtu 15000

ip link add tap6 type gretap remote 10.0.0.7 local 10.0.0.1
ip link set up dev tap6
brctl addif br-wan tap6
ip link set tap6 mtu 15000

ip link add tap7 type gretap remote 10.0.0.8 local 10.0.0.1
ip link set up dev tap7
brctl addif br-wan tap7
ip link set tap7 mtu 15000
