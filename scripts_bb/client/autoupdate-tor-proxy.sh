#!/bin/sh

###############################################################################
#                   If we don't have server tor ID exit
###############################################################################
serverid=$(uci get bridgebox.client.server_id )
torproxy=$(uci get bridgebox.advanced.torproxy)
if [ "$serverid" = "" ]; then
    echo "No remote tor ID exiting" >> /var/log/update-proxy
fi

###############################################################################
#               Wait for internet to be OK
###############################################################################
while true; do
    ping=$(cat /tmp/bb/internet/ping);
    stun=$(cat /tmp/bb/internet/stun);
    udp=$(cat /tmp/bb/internet/udp-port);

    if [ "$ping" != "KO" ]&& [ "$stun" != "KO" ]&& [ "$udp" != "KO" ]; then
        break;
    fi
    sleep 10;
done

echo "We have internet try to update tor proxy" >> /var/log/update-proxy

###############################################################################
#                    Check if current proxy works (if yes exits)
###############################################################################
for i in 1 2 ; do
    if wget-tor-proxy $serverid OK  | grep OK ; then
        echo "Current proxy works, exiting" >> /var/log/update-proxy
        exit 0;
    fi
done
##############################################################################
#                       Clone repo
##############################################################################
url=$(uci get bridgebox.advanced.torproxy_automaj_git)
cd /tmp/
curl $url > list

inittorproxy=$(uci get bridgebox.advanced.torproxy)
inittorproxyparam=$(uci get bridgebox.advanced.torproxyparam)
    
while read line; do
    first=$(echo "$line" | awk '{print $1}' )
    second=$(echo "$line" | awk '{print $2}' )  
    uci set bridgebox.advanced.torproxy=$first
    uci set bridgebox.advanced.torproxyparam=$second
    echo "trying $first $second"
    for i in 1 2 ; do
        if wget-tor-proxy $serverid OK | grep OK ; then
            echo "$line works keeping it" >> /var/log/update-proxy
            uci commit
            exit 0;
        fi
    done
done<list

uci set bridgebox.advanced.torproxy=$inittorproxy
uci set bridgebox.advanced.torproxyparam=$inittorproxyparam
