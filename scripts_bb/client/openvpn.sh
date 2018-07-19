#!/bin/sh

UNDO_FILE=/var/run/ipt_bb_undo.sh

ipt() {
    opt=$1; shift
    echo "iptables -D $*" >> $UNDO_FILE
    iptables $opt $*
    if [ "$?" -ne "0" ]; then
      sleep 2;
      iptables $opt $*
      if [ "$?" -ne "0" ]; then
             sleep 5;
	     iptables $opt $*
      fi
   fi
}

#Remove old iptables
chmod +x /var/run/ipt_bb_undo.sh
/var/run/ipt_bb_undo.sh
rm /var/run/ipt_bb_undo.sh

logfile=/var/log/openvpn-client
  
log() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "$*\n"
  fi
}


/etc/init.d/openvpn stop
/etc/init.d/openvpn disable
killall openvpn

echo "">/etc/dnsmasq.conf
/etc/init.d/dnsmasq restart

sed -i "s/lport .*//g" /etc/openvpn/client.conf
##############################################
#       Get advertisement info
##############################################
. /scripts_bb/client/get-advertised.sh

#################################################
#       Only stun is availiable
################################################
if [ "$mode" = "stun" ]; then

    . /scripts_bb/client/stun.sh    
    if [ "$?" -eq "0" ]; then
        echo "lport $stun_localport">>/etc/openvpn/client.conf
    else
        ##############################################################
        #If Stun does not work we have to go to last resort: tor mode
        ##############################################################
        mode="tor"
        serverid=$(uci get bridgebox.client.server_id )
        ip=$serverid.onion
        proto=tcp
        port=1194
    fi
    
fi

logfile=/var/log/openvpn-client

password=$(uci get bridgebox.client.password )


sed -i "s/remote .*/remote $ip $port/g" /etc/openvpn/client.conf
sed -i "s/proto .*/proto $proto/g" /etc/openvpn/client.conf
echo "$password">/etc/openvpn/client-password
echo "$password">>/etc/openvpn/client-password

mkdir -p /var/log/openvpn/

log "Starting openvpn in mode $mode"
log "Attempting to connect to $ip:$port via $proto with password $password"
if [ "$mode" != "tor" ]; then
    openvpn /etc/openvpn/client.conf > /dev/null 2>&1 &
else
    torsocks openvpn /etc/openvpn/client.conf > /dev/null 2>&1 &
    sleep 5;
fi

sleep 5;
ifconfig -a | grep tap0 > /dev/null 2>&1
    if [ "$?" -ne "0" ]; then
        sleep 5;
    fi

ifconfig -a | grep tap0 > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
    brctl addif br-lan tap0
    ifconfig tap0 up
    
    #stop dnsmasq
    /etc/init.d/dnsmasq stop
    echo "nameserver 8.8.8.8" >/etc/resolv.conf
    
    #Delete iptables that could prevent us from working
    ipt -I FORWARD -i br-lan -o br-wan -j DROP
    ipt -I FORWARD -i br-lan -o wlan0 -j DROP    

    echo "entreprise">/tmp/bb/client/mode
    echo "1" > /sys/class/leds/gl-ar150\:wan/brightness
    log "\033[32;1m Openvpn successfully started \033[0m"
    return 0;
else
    log "Failure"
    /scripts_bb/client/get-offline.sh
    return 1;
fi

