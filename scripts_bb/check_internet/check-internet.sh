#!/bin/sh

mkdir -p /tmp/bb/internet/

clientservermode=$(uci get bridgebox.general.mode);
echo "test ping"
old=$(cat /tmp/bb/internet/internet)
/scripts_bb/check_internet/ping.sh
pingres=$?
if [ "$pingres" -ne "0" ]; then
    if [ "$old" = "OK" ]; then
        echo "WARNING">/tmp/bb/internet/internet
    fi
else
    if [ "$old" = "KO" ]; then
        echo "WARNING">/tmp/bb/internet/internet
    fi
fi

echo "test stun"
/scripts_bb/check_internet/stun.sh
stunres=$?

echo "test tor"
/scripts_bb/check_internet/tor.sh
torres=$?

echo "test udp"
/scripts_bb/check_internet/udp-port.sh
udpres=$?

if [ "$pingres" -eq "0" ]&& [ "$stunres" -eq "0" ]&& [ "$torres" -eq "0" ]&& [ "$udpres" -eq "0" ]; then
    echo "OK">/tmp/bb/internet/internet
    if [ "$clientservermode" = "client" ]; then
        echo "1"> /sys/class/leds/gl-ar150\:green\:lan/brightness
    fi
    return 0;
fi

if [ "$clientservermode" = "client" ]; then
        echo "0"> /sys/class/leds/gl-ar150\:green\:lan/brightness
fi
    
if [ "$pingres" -eq "0" ]|| [ "$stunres" -eq "0" ]|| [ "$torres" -eq "0" ]|| [ "$udpres" -eq "0" ]; then
    echo "WARNING">/tmp/bb/internet/internet
    return 1;
fi

echo "KO">/tmp/bb/internet/internet
return 2;

