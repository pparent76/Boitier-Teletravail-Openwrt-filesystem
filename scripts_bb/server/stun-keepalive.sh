#!/bin/sh


while true; do
    stunserver=$(uci get bridgebox.advanced.stun1)
    stunport=$(uci get bridgebox.advanced.stunport1)
    stunclient $stunserver $stunport --localport $1

    sleep 28;
done
