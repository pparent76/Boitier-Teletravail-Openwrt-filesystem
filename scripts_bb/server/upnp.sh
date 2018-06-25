#!/bin/sh

logfile=/var/log/handle-port-forwarding
  
log() {
  thedate=$(date);
  echo "[$thedate]-[UPNP]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "[UPNP]-$*\n"
  fi
}


log "Trying UpNp"

restestupnp=$(upnpc -P 2>&1)
echo $restestupnp | grep "No IGD UPnP Device found" 2>&1 >/dev/null
if [ "$?" -eq "0" ]; then
    log "\033[41mNo upnp found on network\033[m"
    return 1;
fi


port1=$(uci get bridgebox.advanced.server_port)
port2=$(uci get bridgebox.advanced.server_port_backup1)
port3=$(uci get bridgebox.advanced.server_port_backup2)
port4=$(uci get bridgebox.advanced.server_port_backup3)

ipeth0=$(/sbin/ifconfig br-wan | awk -v line="2" -v field="2" 'NR==line{print $field}' |  sed 's/addr://2g') ;
ip=$( upnpc -l | grep ExternalIPAddress | awk '{print $3}' )

for port in $port1 $port2 $port3 $port4; do
    #############################################
    # Check if our port is not already redirected
    #############################################
    upnpc -l | grep "$ipeth0:1194" | grep "$port"
        if [ "$?" -eq "0" ]; then
            log "UPNP allready redirected"
            echo "$ip">/tmp/bb/server/ip    
            echo "$port">/tmp/bb/server/port
            echo "1">/tmp/bb/server/port-configured
            echo "direct">/tmp/bb/server/port-type 
            return 0
        fi


    #############################################
    # Try to redirect port
    #############################################
    if [ "$ipeth0" != "" ]; then
        #upnpc -d $port tcp -e "bridgebox" > /dev/null 2>&1
        sleep 1;
        # 31536000
        upnpc -a $ipeth0 1194 $port tcp -e "bridgebox" > /tmp/resupnp 2>&1    
        
        upnpc -l | grep "$ipeth0:1194" | grep "$port"

        if [ "$?" -eq "0" ]; then
            log "\033[42mUPnp redirection Made (port $port) \033[m"
            echo "$ip">/tmp/bb/server/ip    
            echo "$port">/tmp/bb/server/port
            echo "1">/tmp/bb/server/port-configured
            echo "direct">/tmp/bb/server/port-type 
            return 0
        fi
    fi
done

log "\033[41mCould not handle Upnp redirection\033[m"
