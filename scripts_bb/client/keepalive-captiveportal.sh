#!/bin/sh

cd /tmp/
while true; do
    wget http://detectportal.firefox.com/success.txt -O /dev/null >/tmp/res-keepalive-captive 2>&1
    sleep 28;
done

