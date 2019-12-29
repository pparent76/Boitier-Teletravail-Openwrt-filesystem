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
if wget-tor-proxy $serverid OK  | grep OK ; then
    echo "Current proxy works, exiting" >> /var/log/update-proxy
fi

##############################################################################
#                       Clone repo
##############################################################################
url=$(uci get bridgebox.advanced.torproxy_automaj_git)
cd /tmp/
git clone $url list
cd list

while read line; do
    echo "trying $line">> /var/log/update-proxy
    wget $serverid.$line/OK --waitretry=1 -t 2 --timeout=20 --dns-timeout=20 --connect-timeout=20 --read-timeout=20 -O /tmp/update-proxy-res  > /dev/null 2&>1  
    if cat /tmp/update-proxy-res | grep OK ; then
        echo "$line works, exiting" >> /var/log/update-proxy
            # TODO change value of proxy
        exit 0;
    fi
done<list
