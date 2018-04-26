#!/bin/sh

port1=$(uci get bridgebox.advanced.server_port)
port2=$(uci get bridgebox.advanced.server_port_backup)
ipeth0=$(/sbin/ifconfig br-wan | awk -v line="2" -v field="2" 'NR==line{print $field}' |  sed 's/addr://2g') ;
ip=$( upnpc -l | grep ExternalIPAddress | awk '{print $3}' )

for port in $port1 $port2; do
    #############################################
    # Check if our port is not already redirected
    #############################################
    upnpc -l | grep "$ipeth0:1194" | grep "$port"
        if [ "$?" -eq "0" ]; then
            echo "UPNP allready redirected"
            echo "$ip">/tmp/bb/server/ip    
            echo "$port">/tmp/bb/server/port
            echo "1">/tmp/bb/server/port-configured
            echo "direct">/tmp/bb/server/port-type 
            exit 0
        fi


    #############################################
    # Try to redirect port
    #############################################
    if [ "$ipeth0" != "" ]; then
        upnpc -d $port tcp -e > /dev/null 2>&1
        sleep 5;
        # 31536000
        upnpc -a $ipeth0 1194 $port tcp -e > /tmp/resupnp 2>&1    
        
        ipport=$(cat /tmp/resupnp | tail -n 1 | grep redirected | grep $ipeth0 |  awk '{print $2}')
        
        upnpc -l | grep "$ipeth0:1194" | grep "$port"

        if [ "$?" -eq "0" ]; then
            echo "UPnp redirection Made"
            echo "$ip">/tmp/bb/server/ip    
            echo "$port">/tmp/bb/server/port
            echo "1">/tmp/bb/server/port-configured
            echo "direct">/tmp/bb/server/port-type 
            exit 0
        fi
    fi
done

echo "Could not handle Upnp redirection"
