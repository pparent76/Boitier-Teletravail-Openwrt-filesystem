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
 
id=$(get-id)

log=$( custom_wget http://proxy.omb.one/OK )
ok=$(cat /tmp/testtor)


if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
else
    echo "result1 : $ok ">>/var/log/test-tor;
    echo "$log" >>/var/log/test-tor;
    ps | grep tor >>/var/log/test-tor;
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

sleep 2;
log=$( custom_wget https://boitier-teletravail.fr/OK )
ok=$(cat /tmp/testtor)

if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
else
    echo "result3: $ok ">>/var/log/test-tor;
    echo "$log" >>/var/log/test-tor;  
    ps | grep tor >>/var/log/test-tor;    
fi


echo "KO" > /tmp/bb/internet/tor
return 1;   
