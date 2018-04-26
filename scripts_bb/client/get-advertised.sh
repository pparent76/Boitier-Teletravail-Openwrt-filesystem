#!/bin/sh

logfile=/var/log/get-advertised
  
log() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile
}


handle_advertised() {
   var=$(cat /tmp/advertised-res | sed 's/^.*BEGINADVERTISE//')
   var=$(echo $var |  sed 's/ENDADVERTISE.*//' )
   export port=$(echo $var | awk '{print $3}') 
   export ip=$(echo $var | awk '{print $2}')    
   export mode=$(echo $var | awk '{print $1}') 
   if [ "$mode" = "direct" ]; then
    export proto="tcp"
   else
    export proto="udp"
   fi
}

serverid=$(uci get bridgebox.client.server_id )

for i in $(seq 1 10); do

    torsocks wget $serverid.onion --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-res > /dev/null 2&>1
    cat /tmp/advertised-res | grep BEGINADVERTISE | grep ENDADVERTISE
    if  [ "$?" -eq "0" ]; then
        log "Could get advertise info with torsocks for $serverid"
        handle_advertised
        return 0;
    fi

    wget $serverid.hiddenservice.net --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-res  > /dev/null 2&>1
    cat /tmp/advertised-res | grep BEGINADVERTISE | grep ENDADVERTISE
    if  [ "$?" -eq "0" ]; then
        log "Could get advertise info with hiddenservice.net for $serverid"    
        handle_advertised
        return 0;
    fi
    
    wget $serverid.onion.to --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-res  > /dev/null 2&>1
    cat /tmp/advertised-res | grep BEGINADVERTISE | grep ENDADVERTISE
    if  [ "$?" -eq "0" ]; then
        log "Could get advertise info with .onion.to for $serverid"        
        handle_advertised
        return 0;
    fi
    sleep 10
done
