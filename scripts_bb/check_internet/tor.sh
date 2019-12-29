#!/bin/sh

custom_wget() {

rm /tmp/testtor
torsocks wget --retry-connrefused --waitretry=1 -t 3 --timeout=10 $1 -O /tmp/testtor  2>&1 &
pid=$!;

sleep 1
i=0;
while [ "$i" -lt "15" ]; do
    i=$(( i+1 ))
    ok=$(cat /tmp/testtor)
    if [ "$ok" = "OK" ]; then
            return 0;
    fi
    sleep 1;    
done

 ps 2>/dev/null | grep " $pid " | grep -v grep >/dev/null 
 res=$?

 if [ "$res" -ne "1" ]; then
	kill -9 $pid
	return 1;
 fi 
}

date >>/var/log/test-tor

###############################################################
#               BEGIN: client only
###############################################################
mode=$(uci get bridgebox.general.mode)
if [ "$mode" = "client" ]; then

        serverid=$(uci get bridgebox.client.server_id )
        wget-tor-proxy $serverid | grep BEGINADVERTISE | grep ENDADVERTISE
        if  [ "$?" -eq "0" ]; then
            echo "OK" > /tmp/bb/internet/tor
            return 0;   
        else
            echo "Special client test through proxy failed">>/var/log/test-tor;
        fi
fi
###############################################################
#               END: client only
###############################################################

###############################################################
#               Try protal detection URL
###############################################################
url=$(uci get bridgebox.advanced.portaldetecturl )
log=$( custom_wget $url )
ok=$(cat /tmp/testtor)
if [ "$ok" != "" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
else
    echo "result1: $ok ">>/var/log/test-tor;
    echo "$log" >>/var/log/test-tor;  
    ps | grep tor >>/var/log/test-tor;    
fi


###############################################################
#               Try our own .onion
############################################################### 
if [ "$mode" = "client" ]; then 
    id=$(uci get bridgebox.client.server_id )
else
    id=$(get-id)
fi

sleep 2;
log=$( custom_wget  $id.onion/OK)
ok=$(cat /tmp/testtor)

if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
else
    echo "result2 : $ok ">>/var/log/test-tor;
    echo "$log" >>/var/log/test-tor;  
    ps | grep tor >>/var/log/test-tor;    
fi

echo "KO" > /tmp/bb/internet/tor
return 1;   
