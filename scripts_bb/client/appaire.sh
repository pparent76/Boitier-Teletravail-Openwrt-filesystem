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
aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )
if [ "$aserverid" != "" ]&& [ "$aserverpubkey" != "" ]&& [ "$avpnaddress" != "" ]; then
        echo "déja appairé"
        exit 1;
fi

code="f0129173a9bf4a889cdd62c30e7c86395b0931f91e";

#Check server is ok.
curl -m 2  --interface br-lan -o /tmp/curl-appaire  http://192.168.8.2:55943/OK
ok=$(cat /tmp/curl-appaire)
if [ "$ok" != "OK" ]; then
    echo "server is not OK!";
    exit 1;
fi

#get challenge
curl -m 2 --interface br-lan  -o /tmp/curl-appaire  http://192.168.8.2:55943/challenge
challenge=$(cat /tmp/curl-appaire)
challengeres=$(echo "$challenge" | openssl aes-256-cbc -e -a -pass pass:$code | tr -d '\n' )
echo "challenge $challenge $challengeres"

#Get other variables
pubkey=$(cat /root/publickey)
mac=$(cat /sys/class/net/eth0/address)

#Urlencodevalues
challengeres=$(urlencode_many_printf $challengeres)
mac=$(urlencode_many_printf $mac)
pubkey=$(urlencode_many_printf $pubkey)

rm /tmp/curl-appaire
#Appairage/Desappairage
echo "curl --interface eth1 http://192.168.8.2:55943/appaire.sh?challenge=$challengeres&mac=$mac&pubkey=$pubkey"
curl -m 16 --interface br-lan  -o /tmp/curl-appaire  "http://192.168.8.2:55943/appaire.sh?challenge=$challengeres&mac=$mac&pubkey=$pubkey"
res=$(cat /tmp/curl-appaire)

#On vérifie si le résultat est OK
echo $res | grep OK >/dev/null 2>&1
if [ "$?" -ne "0" ]; then
    echo "Result was not ok: $res"
    exit 1;
fi

#Recupière les paramètres
serverid=$(echo "$res" | awk '{print $2}')
serverpubkey=$(echo "$res" | awk '{print $3}')
ip=$(echo "$res" | awk '{print $4}')

#Modification des valeurs internes en fonction 
if [ "$ip" = "" ]|| [ "$serverpubkey" = "" ]|| [ "$serverid" = "" ]; then
    echo "Erreur un paramètre est incorrect"
else
        echo "appaire $serverid $serverpubkey $ip"
        echo "res: $res"
        uci set bridgebox.client.server_id=$serverid
        uci set bridgebox.client.serverpubkey=$serverpubkey
        uci set bridgebox.client.vpnaddress=$ip
        uci commit
        /scripts_bb/tools/blink-leds.sh       
fi
