#!/bin/sh
 
urlencode_many_printf () {
  string=$1
  while [ -n "$string" ]; do
    tail=${string#?}
    head=${string%$tail}
    case $head in
      [-._~0-9A-Za-z]) printf %c "$head";;
      *) printf %%%02x "'$head"
    esac
    string=$tail
  done
  echo
}

##################################################################################
#                  Par mesure de sécurité de on ne fait
#                  pas d’appairage sur un boîtier déjà appairé.
##################################################################################
# echo "script desappaire1"
aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )
if [ "$aserverid" = "" ]|| [ "$aserverpubkey" = "" ]|| [ "$avpnaddress" = "" ]; then
        echo "déja deappairé"
        exit 1;
fi

pubkey=$(cat /root/publickey)
pubkey=$(urlencode_many_printf $pubkey)

rm /tmp/res-desappaire
torsocks wget --retry-connrefused --waitretry=1 -t 2 http://$aserverid.onion/desappaire.sh?pubkey=$pubkey --timeout=20 --dns-timeout=20 --connect-timeout=20 --read-timeout=20 -O /tmp/res-desappaire 2> /dev/null
#Vérifie s'il faut se désappairer.
if  cat /tmp/res-desappaire | grep DESAPPAIRE ; then
        echo "desappaire"
        uci set bridgebox.client.server_id=""
        uci set bridgebox.client.serverpubkey=""
        uci set bridgebox.client.vpnaddress=""
        uci commit
        /scripts_bb/tools/blink-leds.sh  
        /scripts_bb/client/get-offline.sh
fi
# echo "script desappaire2"
