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

logfile=/var/log/vpn-client
  
log() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile
  if [ -f "/tmp/verbose" ]; then
    printf "$*\n"
  fi
}

#restart dnsmasq in NAK mode


#     ipt -I OUTPUT -p udp --dport 67 -j DROP  
#     ipt -I OUTPUT -p udp --dport 68 -j DROP    
#     ipt -I OUTPUT -p udp --dport 68 -m string --algo kmp --hex-string '|350106|' -j ACCEPT   
#     ipt -I INPUT -p udp --dport 67 -j DROP  
#     ipt -I INPUT -p udp --dport 68 -j DROP
#     ipt -I INPUT -p udp --dport 67 -s 192.168.8.0/24 -j ACCEPT  
#     ipt -I INPUT -p udp --dport 68 -s 192.168.8.0/24 -j ACCEPT  
#     
#     uci set dhcp.lan.start=10
#     uci set dhcp.lan.limit=20
#     /etc/init.d/dnsmasq restart

ip link del dev wg0 2>/dev/null || true
ip link del dev tap0 2>/dev/null || true

##############################################
#       Get advertisement info
##############################################
. /scripts_bb/client/get-advertised.sh

#################################################
#       Only stun is availiable
################################################
if [ "$mode" = "stun" ]; then

    . /scripts_bb/client/stun.sh    
    if [ "$?" -ne "0" ]; then
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

logfile=/var/log/vpn-client

serverpubkey=$(uci get bridgebox.client.serverpubkey )
vpnaddress=$(uci get bridgebox.client.vpnaddress )

log "Starting wireguard in mode $mode"
log "Attempting to connect to $ip:$port via $proto with pubkey $serverpubkey and vpnaddress $vpnaddress"
if [ "$mode" != "tor" ]; then
    ip link add dev wg0 type wireguard
    wg set wg0 listen-port 1194 private-key /root/privatekey
    wg set wg0 peer $serverpubkey persistent-keepalive 25 allowed-ips 10.0.0.1/32 endpoint $ip:$port
    ip address add $vpnaddress/24 dev wg0
    ip link set wg0 mtu 15000
    ip link set up dev wg0
else
#     TODO TOR mode
     sleep 5;
fi

#todo add root to 10.0.0.1
#todo replace with testping?
sleep 5;
ping -c1 10.0.0.1 -I wg0 > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
        sleep 5;
fi
    
ping -c1 10.0.0.1 -I wg0 > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
    #Add route to make sure all packets to 10.0.0.1 go through wg0
    ip route add 10.0.0.1/32 dev wg0 || true
     
    #Only allow GRE from $vpnaddress to 10.0.0.1 to go through wg0
    # with iptables for security reasons
    ipt -I OUTPUT -d 10.0.0.1 -p 47  -j DROP
    ipt -I OUTPUT -d 10.0.0.1 -p 47 -o wg0  -j ACCEPT
    
    #Add the gretap interface
    ip link add tap0 type gretap remote 10.0.0.1 local $vpnaddress
    ip link set up dev tap0
    ip link set tap0 mtu 15000
    
    sleep 3;
fi

#todo add tap verification
ping -c1 10.0.0.1 -I wg0 > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
    
    brctl addif br-lan tap0
    ifconfig tap0 up
    
    /etc/init.d/dnsmasq stop
#     ifconfig br-lan:1 192.168.1.54
#    dnsmasq --dhcp-relay=192.168.1.54,192.168.1.254,br-lan

    echo "nameserver 8.8.8.8" >/etc/resolv.conf
    
    #Delete iptables that could prevent us from working
    ipt -I FORWARD -i br-lan -o br-wan -j DROP
    ipt -I FORWARD -i br-lan -o wlan0 -j DROP     
    
    echo "entreprise">/tmp/bb/client/mode
    echo "$mode" >/tmp/bb/client/vpn-mode
    echo "1" > /sys/class/leds/gl-ar150\:green\:wan/brightness
    log "\033[32;1m VPN successfully started \033[0m"
    return 0;
else
    log "Failure"
    /scripts_bb/client/get-offline.sh
    return 1;
fi

