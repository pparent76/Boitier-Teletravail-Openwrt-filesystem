#!/bin/sh


# Define Bridge Interface
br="br-wan"
tap="tap0"

# openvpn --mktun --dev $tap
/etc/init.d/openvpn stop
/etc/init.d/openvpn disable
killall openvpn

mkdir -p /var/log/openvpn/
openvpn /etc/openvpn/server.conf &
sleep 5;
brctl addif $br $tap
ifconfig $tap 0.0.0.0 promisc up
