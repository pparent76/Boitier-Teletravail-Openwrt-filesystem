#!/bin/sh

while true; do
    confile=$(ps | grep dnsmasq | grep -v grep | grep -v dnsmasq.sh | awk '{print $7}')
    while ! cat $confile | grep dhcp-range ; do
            client_mode=$(cat /tmp/bb/client/mode)
            if [ "$client_mode" != "entreprise" ]; then
                /etc/init.d/dnsmasq restart;
            else
                sleep 120; 
            fi
            
            sleep 10;
            confile=$(ps | grep dnsmasq | grep -v grep | grep -v dnsmasq.sh | awk '{print $7}')
    done
    
sleep 120;  
done;
