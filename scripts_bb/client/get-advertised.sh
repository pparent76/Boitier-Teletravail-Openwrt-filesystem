#!/bin/sh

logfile=/var/log/get-advertised
  
log() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "$*"
  fi
}


handle_advertised() {
   var=$(cat /tmp/advertised-res | sed 's/^.*BEGINADVERTISE//')
   var=$(echo $var |  sed 's/ENDADVERTISE.*//' )
   export port=$(echo $var | awk '{print $3}' | sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g"| tr "{" " " | tr "}" " ") 
   export ip=$(echo $var | awk '{print $2}'| sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g" | tr "{" " " | tr "}" " ")    
   export localip=$(echo $var | awk '{print $4}' | sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g"| tr "{" " " | tr "}" " " )       
   export mode=$(echo $var | awk '{print $1}' | sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g"| tr "{" " " | tr "}" " " ) 
    export proto="udp"
}

log "Starting get advertise"

serverid=$(uci get bridgebox.client.server_id )

for i in $(seq 1 2); do

    torproxy=$(uci get bridgebox.advanced.torproxy)
    
    wget $serverid.$torproxy --timeout=20 --dns-timeout=20 --connect-timeout=20 --read-timeout=20 -O /tmp/advertised-res  > /dev/null 2&>1
    cat /tmp/advertised-res | grep BEGINADVERTISE | grep ENDADVERTISE
    if  [ "$?" -eq "0" ]; then
        log "Could get advertise info with $torproxy for $serverid"    
        handle_advertised
        return 0;
    fi

    torsocks wget $serverid.onion --timeout=20 --dns-timeout=20 --connect-timeout=20 --read-timeout=20 -O /tmp/advertised-res  > /dev/null 2&>1 
    cat /tmp/advertised-res | grep BEGINADVERTISE | grep ENDADVERTISE
    if  [ "$?" -eq "0" ]; then
        log "Could get advertise info with torsocks for $serverid"
        handle_advertised
        return 0;
    fi
    
    sleep 5
done
