busybox ping -W1 -c1 -I wlan0 8.8.8.8 >/dev/null 2>&1  &
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
