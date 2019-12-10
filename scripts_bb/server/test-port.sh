#!/bin/sh

randm=$(date +%s | sha256sum | head -c 16 ; echo)
# iptables -I INPUT -m string --string 'dummy' -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random" --log-level debug

iptables -I INPUT -m length --length 34 -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$randm"
for i in $(seq 1 10);do
    dummyudp 1000 $2 $1
    dmesg | grep "TEST-PORT-OK-$randm" >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        echo "OK"
#         iptables -D INPUT -m string --string 'dummy' -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random"
        iptables -D INPUT -m length --length 34 -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$randm"
        exit;
    fi
    sleep 1;
done

echo "NO"
#         iptables -D INPUT -m string --string 'dummy' -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$random"
        iptables -D INPUT -m length --length 34 -p udp --dport $3 -j LOG --log-prefix "TEST-PORT-OK-$randm"
