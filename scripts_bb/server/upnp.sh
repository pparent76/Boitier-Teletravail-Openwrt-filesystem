#!/bin/sh

port=$(uci get bridgebox.advanced.server_port)

# 
# ipwlan0=$(/sbin/ifconfig wlan0 | awk -v line="2" -v field="2" 'NR==line{print $field}' |  sed 's/addr://2g') ;
# 
# if [ "$ipwlan0" != "" ]; then
#     upnpc -d $port udp
#     upnpc -a $ipwlan0 1194 $port udp > /tmp/resupnp 2>&1
#     ipport=$(cat /tmp/resupnp | tail -n 1 | grep redirected | awk '{print $2}')
#     ip=$(echo "$ipport" | sed -e "s/:/ /g" | awk '{print $1}')
#     port=$(echo "$ipport" | sed -e "s/:/ /g" | awk '{print $2}')
#   
#    if [ "$ip" != "" ]&& [ "$port" != "" ]; then
#         echo "$ip">/tmp/bb/server/ip    
#         echo "$port">/tmp/bb/server/port
#         echo "1">/tmp/bb/server/port-configured
#         echo "direct">/tmp/bb/server/port-type  
#         exit 0
#     fi
# fi

ipeth0=$(/sbin/ifconfig br-wan | awk -v line="2" -v field="2" 'NR==line{print $field}' |  sed 's/addr://2g') ;


if [ "$ipeth0" != "" ]; then
    #upnpc -d $port udp
    upnpc -d $port tcp    
   # upnpc -a $ipeth0 1195 123 udp -e > /tmp/resupnpudp 2>&1
    upnpc -a $ipeth0 1194 $port tcp -e > /tmp/resupnptcp 2>&1    
    ipport=$(cat /tmp/resupnp | tail -n 1 | grep redirected | awk '{print $2}')
    ip=$(echo "$ipport" | sed -e "s/:/ /g" | awk '{print $1}')
    port=$(echo "$ipport" | sed -e "s/:/ /g" | awk '{print $2}')
    
    if [ "$ip" != "" ]&& [ "$port" != "" ]; then
        echo "$ip">/tmp/bb/server/ip    
        echo "$port">/tmp/bb/server/port
        echo "1">/tmp/bb/server/port-configured
        echo "direct">/tmp/bb/server/port-type 
        exit 0
    fi
fi
