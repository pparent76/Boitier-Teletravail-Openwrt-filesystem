#!/bin/sh



for i in $( seq 1 3 ); do

    stunserver=$(uci get bridgebox.advanced.stun$i)
    stunport=$(uci get bridgebox.advanced.stunport$i)
    
    stunclient $stunserver $stunport > /tmp/stunresi 2>/dev/null

    cat /tmp/stunresi | grep "success"

    
    if [ "$?" -eq "0" ]; then
        echo "stun $stunserver $port ok"
        break
    else
        echo "stun $stunserver $port unreachable"
    fi
done



sleep 1;

cat /tmp/stunresi | grep "success" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
    echo "OK" > /tmp/bb/internet/stun
    return 0;    
fi


echo "KO" > /tmp/bb/internet/stun
return 1;   
