#!/bin/sh

killall autostart-entreprise.sh

#Deinit previous settings.
killall hostapd
killall wpa_supplicant
ip addr flush dev wlan0
ifconfig wlan0 down
ifconfig wlan1 down

if [ ! -f "/tmp/wifi-interfaces-configured" ]; then
    iw dev wlan0 del
    iw dev wlan1 del

    #Add two virtual wifi interfaces
    iw phy phy0 interface add wlan1 type __ap
    iw phy phy0 interface add wlan0 type station

    sleep 1

    #Todo: we need to change mac adresses
    #get mac address of wlan0
    mac=$(ifconfig -a wlan0 | awk '/HWaddr/ {print $5}')
    #Add 0x10 to this mac address
    machex=$( echo "$mac" | tr -d ':' ) # to remove colons
    macdec=$( printf "%d\n" 0x$machex ) # to convert to decimal
    macdec1=$( expr $macdec - 1 ) # to subtract one 
    machex1=$( printf "%x\n" $macdec1 ) # to convert to hex again 
    macfinal1=$(echo $machex1 | sed 's/\(..\)/\1:/g;s/:$//' )
    macdec1=$( expr $macdec1 - 1 ) # to subtract one 
    machex1=$( printf "%x\n" $macdec1 ) # to convert to hex again 
    macfinal2=$(echo $machex1 | sed 's/\(..\)/\1:/g;s/:$//' )

    #set it to wlan0
    ifconfig wlan0 down
    ifconfig wlan1 down    
    ip link set wlan1 address $macfinal1
    ip link set wlan0 address $macfinal2    

    sleep 1
fi

touch /tmp/wifi-interfaces-configured

################################################
#           Station (client) part
################################################
ssid_sta=$(uci get bridgebox.wifi_sta.ssid)
hidden_sta=$(uci get bridgebox.wifi_sta.hidden)
enctype_sta=$(uci get bridgebox.wifi_sta.enctype)
key_sta=$(uci get bridgebox.wifi_sta.key)
enabled_sta=$(uci get bridgebox.wifi_sta.enabled)
channel_sta=""

if [ "$enabled_sta" = "1" ]; then
    rm /etc/wpasupplicant.conf
    echo "update_config=1" >>/etc/wpasupplicant.conf
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=root" >>/etc/wpasupplicant.conf
    echo "network={">>/etc/wpasupplicant.conf
    echo "ssid=\"$ssid_sta\"">>/etc/wpasupplicant.conf
    if [ "$hidden_sta" = "1" ]; then
        echo "scan_ssid=1">>/etc/wpasupplicant.conf
    fi
    
    case $enctype_sta in
        "open")
            echo "key_mgmt=NONE">>/etc/wpasupplicant.conf
        ;;
        "wep-passphrase")
            echo "key_mgmt=NONE">>/etc/wpasupplicant.conf
            echo "wep_key0=\"$key_sta\"">>/etc/wpasupplicant.conf   
            echo "wep_tx_keyidx=0">>/etc/wpasupplicant.conf              
        ;;
        "wep-hex")
            echo "key_mgmt=NONE">>/etc/wpasupplicant.conf
            echo "wep_key0=0x$key_sta">>/etc/wpasupplicant.conf   
            echo "wep_tx_keyidx=0">>/etc/wpasupplicant.conf              
        ;;        
        "wpa")
            echo "psk=\"$key_sta\"">>/etc/wpasupplicant.conf
        ;;    
    esac
    
    echo "}">>/etc/wpasupplicant.conf

    wpa_supplicant -Dnl80211 -iwlan0 -c/etc/wpasupplicant.conf  >/var/log/wpa_supplicant 2>&1  & 
    udhcpc -i wlan0 >/var/log/udhcp_wifi 2>&1  & 
    
    sleep 3
    channel_sta=$(iw wlan0 info |grep channel | awk '{print $2}')
    
    #retry 1
    if [ "$channel_sta" = "" ]; then
        sleep 5;
        channel_sta=$(iw wlan0 info |grep channel | awk '{print $2}')
    fi
    
    #retry 2
    if [ "$channel_sta" = "" ]; then
        sleep 10;
        channel_sta=$(iw wlan0 info |grep channel | awk '{print $2}')
    fi    
fi

if [ "$channel_sta" = "" ]; then
    killall wpa_supplicant
    channel_sta=6
fi

################################################
#            Ap part
################################################
ssid_ap=$(uci get bridgebox.wifi_ap.ssid)
key_ap=$(uci get bridgebox.wifi_ap.key)
enabled_ap=$(uci get bridgebox.wifi_ap.enabled)
clientservermode=$(uci get bridgebox.general.mode)

if [ "$enabled_ap" = "1" ]&& [ "$clientservermode" != "server" ]; then
    rm /etc/hostapd.conf  
    echo "country_code=FR">/etc/hostapd.conf
    echo "ieee80211n=1">>/etc/hostapd.conf
    echo "ieee80211d=1">>/etc/hostapd.conf
    echo "interface=wlan1">>/etc/hostapd.conf
    echo "ssid=$ssid_ap" >>/etc/hostapd.conf  
    echo "wpa=2">>/etc/hostapd.conf
    echo "wpa_passphrase=$key_ap">>/etc/hostapd.conf
    echo "wpa_key_mgmt=WPA-PSK">>/etc/hostapd.conf
    echo "wpa_pairwise=CCMP">>/etc/hostapd.conf
    echo "rsn_pairwise=CCMP">>/etc/hostapd.conf
    echo "hw_mode=g" >>/etc/hostapd.conf
    echo "bridge=br-lan" >>/etc/hostapd.conf    
    if [ "$channel_sta" != "" ]; then
        echo "channel=$channel_sta">>/etc/hostapd.conf  
    fi
    hostapd /etc/hostapd.conf >/var/log/hostapd 2>&1 &
fi

/scripts_bb/check_internet/check-internet.sh &
