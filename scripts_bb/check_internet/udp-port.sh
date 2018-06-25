#!/bin/sh

res=0;
stunclient stun1.l.google.com 19302 $option > /tmp/stunresi

sleep 1;
cat /tmp/stunresi | grep "success" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
        res=$(( res + 1 ))
fi

stunclient stun.sipgate.net 10000 $option > /tmp/stunresi

sleep 1;
cat /tmp/stunresi | grep "success" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
        res=$(( res + 1 ))
fi

stunclient stun.1und1.de 3478 $option > /tmp/stunresi

sleep 1;
cat /tmp/stunresi | grep "success" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
        res=$(( res + 1 ))
fi


if [ "$res" -gt "2" ]; then
    echo "OK" > /tmp/bb/internet/udp-port
    return 0;  
else
    echo "KO" > /tmp/bb/internet/udp-port
    return 1;  
fi
