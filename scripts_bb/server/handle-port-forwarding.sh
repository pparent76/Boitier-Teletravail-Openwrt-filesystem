#!/bin/sh

#!/bin/sh

logfile=/var/log/handle-port-forwarding
  
log() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "$*\n"
  fi
}

logcontent=$(tail -n 1000 /var/log/handle-port-forwarding )
echo "$logcontent" > /var/log/handle-port-forwarding 




log "\033[44m!!!!!!START HANDLING PORT FORWARDING!!!!!!!\033[m"

wg | grep 1194 >/dev/null 2>&1
wgres=$?
 if [ "$wgres" -ne 0 ]; then
     /scripts_bb/server/vpn.sh
 fi

#######################################################
#           Begin port opening
#######################################################
echo "0" > /tmp/bb/server/port-configured

/scripts_bb/server/check-port-direct.sh

#If port is not yet configured we try upnp
if [ $(cat /tmp/bb/server/port-configured) -ne "1" ]; then
    /scripts_bb/server/upnp.sh
fi

#If port is not yet configured we try stun
if [ $(cat /tmp/bb/server/port-configured) -ne "1" ]; then
    /scripts_bb/server/stun.sh
else
    killall stun-keepalive.sh
fi

/scripts_bb/server/advertise.sh

serverok=1;
torstate=$(cat /tmp/bb/internet/tor)
porttype=$(cat /tmp/bb/server/port-type)
wg | grep 1194 >/dev/null 2>&1
wgres=$?

if [ "$torstate" != "OK" ]; then
    serverok=0;
fi

if [ "$porttype" != "direct" ]&& [ "$porttype" != "stun" ]; then
    serverok=0;
fi

if [ "$wgres" -ne 0 ]; then
    serverok=0;
fi

if [ "$porttype" = "direct" ]; then
    echo "1"> /sys/class/leds/gl-ar150\:lan/brightness
else
    echo "0"> /sys/class/leds/gl-ar150\:lan/brightness
fi

if [ "$serverok" -eq "1" ]; then
    echo "1"> /sys/class/leds/gl-ar150\:wan/brightness
else
    echo "0"> /sys/class/leds/gl-ar150\:wan/brightness
fi

#######################################################
#           End port opening
####################################################### 
