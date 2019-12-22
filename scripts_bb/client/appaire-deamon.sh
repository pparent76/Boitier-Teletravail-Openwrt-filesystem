#!/bin/sh

aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )

while [ "$aserverid" = "" ]|| [ "$aserverpubkey" = "" ]|| [ "$avpnaddress" = "" ]; do
/scripts_bb/client/appaire.sh >>/var/log/appaire
aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )
sleep 2; 
done
