#!/bin/sh

UNDO_FILE=/var/run/ipt_bb_undo.sh

ipt() {
    opt=$1; shift
    echo "iptables -D $*" >> $UNDO_FILE
    iptables $opt $*
    if [ "$?" -ne "0" ]; then
      sleep 2;
      iptables $opt $*
      if [ "$?" -ne "0" ]; then
             sleep 5;
	     iptables $opt $*
      fi
   fi
}

#Redirect everything to localhost (Captive portail like function)
ipt -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
ipt -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80

#Allow the web interface to be reachable from 2.2.2.2
ifconfig br-lan:0 2.2.2.2 netmask 255.255.255.255
iptables -t nat -F PREROUTING
ebtables -t broute -A BROUTING -p ipv4 -i wlan1 --ip-dst 2.2.2.2 -j redirect --redirect-target DROP
ebtables -t broute -A BROUTING -p ipv4 -i eth1 --ip-dst 2.2.2.2 -j redirect --redirect-target DROP
iptables -I FORWARD -i eth0 -s 2.2.2.2 -j DROP
ip rule add fwmark 2 table 3
iptables -t mangle -I OUTPUT -s 2.2.2.2 -j MARK --set-mark 2
ip route add 0.0.0.0/0 dev br-lan table 3

