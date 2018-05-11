#!/bin/sh


# Define Bridge Interface
br="br-wan"
tap="tap0"
tap2="tap1"

# openvpn --mktun --dev $tap
/etc/init.d/openvpn stop
/etc/init.d/openvpn disable
killall openvpn

mkdir -p /var/log/openvpn/

cp /etc/openvpn/server.conf /etc/openvpn/server-udp.conf
sed -i "s/tcp-server/udp/g" /etc/openvpn/server-udp.conf
sed -i "s/$tap/$tap2/g" /etc/openvpn/server-udp.conf
sed -i "s#log-append /var/log/openvpn/server.log#log-append /var/log/openvpn/server-udp.log#g" /etc/openvpn/server-udp.conf

openvpn /etc/openvpn/server.conf &
openvpn /etc/openvpn/server-udp.conf &

sleep 5;
brctl addif $br $tap
brctl addif $br $tap2
ifconfig $tap 0.0.0.0 promisc up
ifconfig $tap2 0.0.0.0 promisc up

