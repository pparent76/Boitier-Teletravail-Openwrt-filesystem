#!/bin/sh

#clean-all
rm /etc/easy-rsa/keys/myserver.crt
rm /etc/easy-rsa/keys/myserver.key
rm /etc/easy-rsa/keys/client.crt
rm /etc/easy-rsa/keys/client.key

#We should edit vars and put a random name.
. /etc/easy-rsa/vars

pkitool --server myserver
pkitool  client
rm -r /etc/openvpn/keys/
cp -r /etc/easy-rsa/keys /etc/openvpn/
