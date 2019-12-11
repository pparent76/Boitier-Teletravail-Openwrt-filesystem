#!/bin/sh

random=$(date +%s | sha256sum | head -c 16 ; echo)
iptables -I INPUT -m string --string 'dummy' --algo bm -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random" 

for i in $(seq 1 10);do
    dummyudp 1000 $2 $1
    dmesg | grep "TEST-PORT-OK-$random" >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        echo "OK"
         iptables -D INPUT -m string --string 'dummy' --algo bm -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random"
        exit;
    fi
    sleep 1;
done

echo "NO"
         iptables -D INPUT -m string --string 'dummy' --algo bm -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random"
