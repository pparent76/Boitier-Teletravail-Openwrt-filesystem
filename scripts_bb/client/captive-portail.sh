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

#STOP VPN
ip link del dev wg0 2>/dev/null || true
ip link del dev tap0 2>/dev/null || true

/etc/init.d/dnsmasq stop

  
ipt -t nat -I POSTROUTING -o wlan0 -j MASQUERADE
ipt -I FORWARD -j ACCEPT

#TODO we need to write dnsmasq conf so that it replies correct DNS.

echo "">/etc/dnsmasq.conf
# uci set dhcp.lan.start=100
# uci set dhcp.lan.limit=200
/etc/init.d/dnsmasq restart
echo  "nameserver 127.0.0.1" > /etc/resolv.conf

echo "local">/tmp/bb/client/mode
echo "0" > /sys/class/leds/gl-ar150\:wan/brightness
