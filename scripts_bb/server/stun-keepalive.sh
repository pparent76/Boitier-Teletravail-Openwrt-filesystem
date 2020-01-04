#!/bin/sh


while true; do
    localport=$(cat /tmp/bb/server/stun-local-port)
    stunserver=$(uci get bridgebox.advanced.stun1)
    stunport=$(uci get bridgebox.advanced.stunport1)
    type=$(cat /tmp/bb/server/port-type )
    
    if [ "$localport" != ""  ]&& [ "$type" = "stun" ]; then
        stunclient $stunserver $stunport --localport $localport
    fi
    sleep 28;
done
