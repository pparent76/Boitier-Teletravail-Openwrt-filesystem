#!/bin/sh

logfile=/var/log/handle-port-forwarding
  
log() {
  thedate=$(date);
  echo "[$thedate]-[STUN]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "[STUN]-$*\n"
  fi
}

handlesuccess() {
    sleep 2;
    localport=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )
    mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )  
    publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )     
    iptables -t nat -A PREROUTING -i br-wan -p udp --dport $localport -j REDIRECT --to-port 1194
    
    if cat /tmp/bb/server/port-type | grep stun; then
        lport=$(cat /tmp/bb/server/stun-local-port )
        iptables -t nat -D PREROUTING -i br-wan -p udp --dport $lport -j REDIRECT --to-port 1194 
    fi
    
    log "\033[42mStun redirection Made on port $mappedport\033[m"
    echo "$publicip">/tmp/bb/server/ip    
    echo "$mappedport">/tmp/bb/server/port
    echo "$localport">/tmp/bb/server/stun-local-port    
    echo "1">/tmp/bb/server/port-configured
    echo "stun">/tmp/bb/server/port-type 
    

}

option=""
log "Trying STUN"



for j in $( seq 1 5 ); do

    if [ "$j" -eq "1" ]; then
        port=$(uci get bridgebox.advanced.server_port)
    else
        port=$(uci get bridgebox.advanced.server_port_backup$j)
    fi
    if [ "$j" -eq "5" ]; then
        option=""
    else
        option="--localport $port"
    fi

    for i in $( seq 1 3 ); do
    
        stunserver=$(uci get bridgebox.advanced.stun$i)
        stunport=$(uci get bridgebox.advanced.stunport$i)
        
        stunclient $option $stunserver $stunport > /tmp/stunres 2>/dev/null
        
        cat /tmp/stunres | grep "success"
        if [ "$?" -ne "0" ]; then
            sleep 1;
            stunclient $option $stunserver $stunport > /tmp/stunres 2>/dev/null
        fi
    
        cat /tmp/stunres | grep "success"
        
        if [ "$?" -eq "0" ]; then
             mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  ) 
             if [ "$mappedport" -le "1024" ]|| [ "$j" -eq "5" ]; then
                handlesuccess;
                return 0;
             fi
        fi
    done
done
