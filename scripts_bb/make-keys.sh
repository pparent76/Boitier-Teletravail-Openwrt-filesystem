#!/bin/sh

cd /root/

if [ ! -e "privatekey" ]; then
 wg genkey > privatekey
 wg pubkey < privatekey > publickey
fi
