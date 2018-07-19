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

/etc/init.d/openvpn stop
killall openvpn

ipt -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 443 -j REDIRECT --to-ports 443
ipt -I PREROUTING -t nat -i br-lan -p tcp --dst 0.0.0.0/0 --dport 80 -j REDIRECT --to-ports 80


#TODO we need to write dnsmasq conf so that it allways reply the same IP to DNS requests.

echo "address=/#/2.2.2.2">/etc/dnsmasq.conf
/etc/init.d/dnsmasq restart
echo  "nameserver 8.8.8.8" > /etc/resolv.conf
echo "offline">/tmp/bb/client/mode
echo "0" > /sys/class/leds/gl-ar150\:wan/brightness
