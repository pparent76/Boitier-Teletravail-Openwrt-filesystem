#!/bin/sh

/etc/init.d/openvpn stop
killall openvpn

ip="86.71.154.196"
port="443"
proto="tcp"
password="Pierre"

sed -i "s/remote .*/remote $ip $port/g" /etc/openvpn/client.conf
sed -i "s/proto .*/proto $proto/g" /etc/openvpn/client.conf
echo "$password">/etc/openvpn/client-password
echo "$password">>/etc/openvpn/client-password

mkdir -p /var/log/openvpn/

openvpn /etc/openvpn/client.conf > /dev/null 2>&1 &
sleep 10;

ifconfig -a | grep tap0 > /dev/null 2>&1

if [ "$?" -eq "0" ]; then

    brctl addif br-lan tap0
    ifconfig tap0 up
    
    #stop dnsmasq
    /etc/init.d/dnsmasq stop
    echo "nameserver 8.8.8.8" >/etc/resolv.conf
    
    #Delete iptables that could prevent us from working
    iptables -t nat -D POSTROUTING -o wlan0 -j MASQUERADE
    iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
    iptables -D PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80
fi
