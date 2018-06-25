custom_ping() {

busybox ping -W1 -c1 $1 >/dev/null 2>&1  &
pid=$!;

 ps 2>/dev/null | grep " $pid " | grep -v grep >/dev/null 
 res=$?

 if [ "$res" -eq "1" ]; then
	wait $pid
	return $?
 fi
 
sleep 1;

 ps 2>/dev/null | grep " $pid " | grep -v grep >/dev/null 
 res=$?

 if [ "$res" -eq "1" ]; then
	wait $pid
	return $?	
 else
	kill -9 $pid
	return 1;
 fi 


}

custom_ping 8.8.8.8
if [ "$?" -eq "0" ]; then
    echo "8.8.8.8" > /tmp/bb/internet/ping
    return 0;
fi


custom_ping google.com
if [ "$?" -eq "0" ]; then
    echo "google.com" > /tmp/bb/internet/ping
    return 0;    
fi

custom_ping fr.wikipedia.org
if [ "$?" -eq "0" ]; then
    echo "fr.wikipedia.org" > /tmp/bb/internet/ping
    return 0;    
fi

custom_ping amazon.com
if [ "$?" -eq "0" ]; then
    return 0;
    echo "amazon.com" > /tmp/bb/internet/ping
fi

custom_ping facebook.com
if [ "$?" -eq "0" ]; then
    echo "facebook.com" > /tmp/bb/internet/ping
    return 0;    
fi

custom_ping leboncoin.fr
if [ "$?" -eq "0" ]; then
    echo "leboncoin.fr" > /tmp/bb/internet/ping
    return 0;    
fi

custom_ping telework-box.com
if [ "$?" -eq "0" ]; then
    echo "telework-box.com" > /tmp/bb/internet/ping
    return 0;    
fi

echo "KO" > /tmp/bb/internet/ping
return 1;
