#!/bin/sh

stunclient stun.12voip.com 3478 > /tmp/stunres

cat /tmp/stunres | grep "success"

if [ "$?" -eq "0" ]; then
    localport=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )
    mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )  
    publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )  
    iptables -t nat -A PREROUTING -i br-wan -p udp --dport $localport -j REDIRECT --to-port 1194
    echo "Stun redirection Made"
    echo "$publicip">/tmp/bb/server/ip    
    echo "$mappedport">/tmp/bb/server/port
    echo "$localport">/tmp/bb/server/stun-local-port    
    echo "1">/tmp/bb/server/port-configured
    echo "stun">/tmp/bb/server/port-type 
fi

