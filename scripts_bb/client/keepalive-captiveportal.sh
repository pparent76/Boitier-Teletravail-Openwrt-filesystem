#!/bin/sh

cd /tmp/
url=$(uci get bridgebox.advanced.portaldetecturl )
while true; do
    wget $url -O /dev/null >/tmp/res-keepalive-captive 2>&1
    sleep 28;
done

