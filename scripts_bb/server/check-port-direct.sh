#!/bin/sh

logfile=/var/log/handle-port-forwarding
  
log() {
  thedate=$(date);
  echo "[$thedate]-[Direct-Port]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "[Direct-Port]-$*\n"
  fi
}

log "Checking if ports are allready redirected"

publicip="" ;

#Get our public ip by requesting stun servers
for i in $( seq 1 3 ); do

    stunserver=$(uci get bridgebox.advanced.stun$i)
    stunport=$(uci get bridgebox.advanced.stunport$i)
    
    stunclient $stunserver $stunport > /tmp/stunres 2>/dev/null

    cat /tmp/stunres | grep "success"
    
    if [ "$?" -eq "0" ]; then
        break
    fi
done

cat /tmp/stunres | grep "success"

if [ "$?" -eq "0" ]; then
    publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )  
fi


if [ "$publicip" = "" ]; then
    wget  https://api.ipify.org/?format=txt -O /tmp/publicip  >/dev/null 2>&1
    publicip=$(cat /tmp/publicip | sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g" | tr "{" " " | tr "}" " ")
fi

port1=$(uci get bridgebox.advanced.server_port)
port2=$(uci get bridgebox.advanced.server_port_backup1)
port3=$(uci get bridgebox.advanced.server_port_backup2)
port4=$(uci get bridgebox.advanced.server_port_backup3)

for port in $port1 $port2 $port3 $port4; do
    /scripts_bb/server/test-openvpn.py -t --retrycount 2 --timeout 5 --tls-auth /etc/openvpn/keys/ta.key  --tls-auth-inverse  -p $port $publicip | grep "OK"
    if [ "$?" -eq "0" ]; then
            log "\033[42mPort $port redirected\033[m"
            echo "$publicip">/tmp/bb/server/ip    
            echo "$port">/tmp/bb/server/port
            echo "1">/tmp/bb/server/port-configured
            echo "direct">/tmp/bb/server/port-type 
            exit 0
    fi
done

log "\033[41mNo port already redirected\033[m"
 
