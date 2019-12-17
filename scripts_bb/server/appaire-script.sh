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



rmmod gpio_button_hotplug >/dev/null 2>&1
sleep 1;
echo  "8" >  /sys/class/gpio/export >/dev/null 2>&1
value=$(cat  /sys/class/gpio/gpio8/value) >/dev/null 2>&1

if [ "$value" = "1" ]; then
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
        if [ "$ip" != "" ]; then
            echo "$1#$2#sansnom#$ip" >> /etc/server-codes
            echo $ip
            mustblink=1;
        fi
     fi   
else
    cat /etc/server-codes | grep $1 >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        mustblink=1;
    fi
    sed -i "/$1/d" /etc/server-codes
fi

##########################################################
#Blink leds for 10s
##########################################################
if [ "$mustblink" -eq "1" ]; then
    j=0;
    initlan=$( cat /sys/class/leds/gl-ar150\:green\:lan/brightness)
    initwan=$( cat /sys/class/leds/gl-ar150\:green\:wan/brightness)

    for i in $( seq 1 10 ); do
        echo "$j"> /sys/class/leds/gl-ar150\:green\:lan/brightness
        echo "$j"> /sys/class/leds/gl-ar150\:green\:wan/brightness
        sleep 1;
        if [ "$j" -eq "0" ]; then
            j=1;
        else
            j=0;
        fi
    done

    echo "$initlan"> /sys/class/leds/gl-ar150\:green\:lan/brightness
    echo "$initwan"> /sys/class/leds/gl-ar150\:green\:wan/brightness
    
exit 0;
fi

exit 1;

