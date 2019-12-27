#!/bin/sh

while true;
do 
    /usr/sbin/ntpd -n -S /usr/sbin/ntpd-hotplug -p 0.openwrt.pool.ntp.org -p 1.openwrt.pool.ntp.org -p 0.fr.pool.ntp.org -p 1.fr.pool.ntp.org -q
    if [ $? -eq 0 ]; then
        break;
    fi
    sleep 2;
done

