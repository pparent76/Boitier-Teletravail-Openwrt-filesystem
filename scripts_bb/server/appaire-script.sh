#!/bin/sh

random=$(date +%s | sha256sum | head -c 42)
ps | grep appaire-script.sh | grep -v grep | wc -l >/tmp/counttest$random
res=$(cat /tmp/counttest$random)
rm /tmp/counttest$random
if [ "$res" -gt "1" ]; then
    echo "Another instance is running ( $res )"
    exit 1;
fi
mustblink=0;


cat /etc/server-codes | grep "$1" >/dev/null 2>&1
    if [ "$?" -ne "0" ]; then
        i=2;
        ip="10.0.0.$i";
        while grep "$ip" /etc/server-codes >/dev/null 2>&1 ; do 
            i=$(( i + 1 ));
             ip="10.0.0.$i";
        done
        if [ "$i" -gt "8" ]; then
            ip="";
        fi
        stunpass=$(date +%s | sha256sum | head -c 42)
        if [ "$ip" != "" ]; then
            echo "$1#$2#$ip#$stunpass#sansnom" >> /etc/server-codes
            echo "$ip $stunpass"
            mustblink=1;
            sed -i "/$2/d" /etc/desappaire
            /scripts_bb/server/vpn.sh 2> /dev/null > /dev/null &
        fi
     fi   

##########################################################
#Blink leds for 10s
##########################################################
if [ "$mustblink" -eq "1" ]; then
/scripts_bb/tools/blink-leds.sh 2> /dev/null > /dev/null
exit 0;
fi

exit 1;

