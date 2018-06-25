#!/bin/sh

logfile=/var/log/handle-port-forwarding
  
log() {
  thedate=$(date);
  echo "[$thedate]-[STUN]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "[STUN]-$*\n"
  fi
}

option=""
log "Trying STUN"

if [ "$(cat /tmp/bb/server/port-type)" = "stun" ]; then
    localport=$(cat /tmp/bb/server/stun-local-port)
    option="--localport $localport"
else    
    log "Stop keep alive"
    killall stun-keepalive.sh
fi

for i in $( seq 1 3 ); do

    stunserver=$(uci get bridgebox.advanced.stun$i)
    stunport=$(uci get bridgebox.advanced.stunport$i)
    
    stunclient $stunserver $stunport > /tmp/stunres 2>/dev/null

    cat /tmp/stunres | grep "success"
    
    if [ "$?" -eq "0" ]; then
        break
    fi
done

sleep 2;

cat /tmp/stunres | grep "success"

if [ "$?" -eq "0" ]; then
    localport=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )
    mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )  
    publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )  
    iptables -t nat -A PREROUTING -i br-wan -p udp --dport $localport -j REDIRECT --to-port 1194
    log "\033[42mStun redirection Made on port $mappedport\033[m"
    echo "$publicip">/tmp/bb/server/ip    
    echo "$mappedport">/tmp/bb/server/port
    echo "$localport">/tmp/bb/server/stun-local-port    
    echo "1">/tmp/bb/server/port-configured
    echo "stun">/tmp/bb/server/port-type 
    
    pidof stun-keepalive.sh
    if [ "$?" -ne "0" ]; then
        log "Starting keep alive"
        /scripts_bb/server/stun-keepalive.sh $localport &
    fi
    
    return 0;
fi

