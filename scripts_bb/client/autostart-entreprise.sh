#!/bin/sh

internet=$(cat /tmp/bb/internet/internet)

if [ "$internet" = "OK" ]; then
    /scripts_bb/client/vpn.sh &
    return 1;
fi

ping=$(cat /tmp/bb/internet/ping);
stun=$(cat /tmp/bb/internet/stun);
udp=$(cat /tmp/bb/internet/udp-port);

if [ "$ping" != "KO" ]&& [ "$stun" != "KO" ]&& [ "$udp" != "KO" ]; then
    /scripts_bb/client/vpn.sh &
fi



sleep 60;

mode=$(cat /tmp/bb/client/mode)
if [ "$mode" = "entreprise" ]; then
    return 1;
fi

killall vpn.sh
/scripts_bb/check_internet/check-internet.sh
internet=$(cat /tmp/bb/internet/internet)

if [ "$internet" = "OK" ]; then
    /scripts_bb/client/vpn.sh &
    return 1;
fi

ping=$(cat /tmp/bb/internet/ping);
stun=$(cat /tmp/bb/internet/stun);
udp=$(cat /tmp/bb/internet/udp-port);

if [ "$ping" != "KO" ]&& [ "$stun" != "KO" ]&& [ "$udp" != "KO" ]; then
    /scripts_bb/client/vpn.sh &
    return 1;
fi

sleep 240;
/scripts_bb/check_internet/check-internet.sh
internet=$(cat /tmp/bb/internet/internet)

if [ "$internet" = "OK" ]; then
    /scripts_bb/client/vpn.sh &
    return 1;
fi
