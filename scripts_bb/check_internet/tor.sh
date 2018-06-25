#!/bin/sh

custom_wget() {

rm /tmp/testtor
torsocks wget --retry-connrefused --waitretry=1 -t 3 --timeout=10 $1 -O /tmp/testtor >>/var/log/test-tor 2>&1 &
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

 
id=$(get-id)

custom_wget http://proxy.omb.one/OK 
ok=$(cat /tmp/testtor)

date >>/var/log/test-tor
echo "result1 : $ok ">>/var/log/test-tor;
if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
fi

custom_wget  $id.onion/OK
ok=$(cat /tmp/testtor)

echo "result2 : $ok ">>/var/log/test-tor;
if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
fi

custom_wget http://www.bridge-box.com/OK 
ok=$(cat /tmp/testtor)

date >>/var/log/test-tor
echo "result3 : $ok ">>/var/log/test-tor;
if [ "$ok" = "OK" ]; then
    echo "OK" > /tmp/bb/internet/tor
    return 0;   
fi


echo "KO" > /tmp/bb/internet/tor
return 1;   
