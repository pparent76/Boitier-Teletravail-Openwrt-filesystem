#!/bin/sh

aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )

while true ; do
    #####################################################################################
    #                                Boucle d'appairage
    #####################################################################################
    while [ "$aserverid" = "" ]|| [ "$aserverpubkey" = "" ]|| [ "$avpnaddress" = "" ]; do
    /scripts_bb/client/appaire.sh >>/var/log/appaire
    aserverid=$(uci get bridgebox.client.server_id )
    aserverpubkey=$(uci get bridgebox.client.serverpubkey )
    avpnaddress=$(uci get bridgebox.client.vpnaddress )
    sleep 2; 
    done

    #####################################################################################
    #                               Boucle d'attente de tor
    #####################################################################################
    echo "passage en mode test tor"  >>/var/log/appaire     
    tor=$(cat /tmp/bb/internet/tor)
    while [ "$tor" != "OK" ]; do
    sleep 5;
    tor=$(cat /tmp/bb/internet/tor)
    done
    
    echo "passage en mode desapairage" >>/var/log/appaire   
    #####################################################################################
    #                                Boucle de desapairage
    ##################################################################################### 
    aserverid=$(uci get bridgebox.client.server_id )
    while [ "$aserverid" != "" ]; do
    /scripts_bb/client/desappaire.sh >>/var/log/appaire  
    aserverid=$(uci get bridgebox.client.server_id )
        if [ "$aserverid" != "" ]; then
        sleep 180;
        fi
    done
    echo "passage en mode apairage"  >>/var/log/appaire     
done
