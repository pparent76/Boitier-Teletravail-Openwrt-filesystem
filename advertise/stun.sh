#!/bin/sh

echo "Content-type: text/html"
echo ""

# Récuperation des variables
if [ "$REQUEST_METHOD" = "POST" ]; then
read QUERY_STRING
fi
QUERY=`echo $QUERY_STRING | sed -e "s/=/='/g" -e "s/&/';/g" -e "s/+/ /g" -e "s/%0d%0a/<BR>/g" -e "s/$/'/" -e "s/%2C/,/g"`
eval $QUERY

sourceport=$(cat /tmp/bb/server/stun-local-port)

if [ "sourceport" != "" ]; then
    sudo /usr/bin/dummyudp $sourceport $ip $port
    if [ "$?" -eq "0" ]; then
	sudo /usr/sbin/conntrack -D -d $ip -p udp --dport $port --sport $sourceport >/tmp/resconntrack 2>&1 
        echo "OK"
    fi
fi
