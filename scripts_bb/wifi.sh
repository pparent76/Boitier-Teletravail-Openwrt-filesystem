#!/bin/sh

#Deinit previous settings.
killall hotapd
killall wpa_supplicant
iw dev wlan0 del
iw dev wlan1 del

#Add two virtual wifi interfaces
iw phy phy0 interface add wlan1 type __ap
iw phy phy0 interface add wlan0 type station

#Todo: we need to change mac adresses

sleep 2

################################################
#           Station (client) part
################################################
ssid_sta=$(uci get bridgebox.wifi-sta.ssid)
hidden_sta=$(uci get bridgebox.wifi-sta.hidden)
enctype_sta=$(uci get bridgebox.wifi-sta.enctype)
key_sta=$(uci get bridgebox.wifi-sta.key)
enabled_sta=$(uci get bridgebox.wifi-sta.enabled)

if [ "$enabled_sta" = "1" ]; then
    #TODO edit /etc/wpasupplicant.conf (ssid + key)
    rm /etc/wpasupplicant.conf
    echo "network={">/etc/wpasupplicant.conf
    echo "ssid=\"$ssid_sta\"">>/etc/wpasupplicant.conf
    if [ "$hidden_sta" = "1" ]; then
        echo "scan_ssid=1">>/etc/wpasupplicant.conf
    fi
    echo "}">>/etc/wpasupplicant.conf

    wpa_supplicant -Dnl80211 -iwlan0 -c/etc/wpasupplicant.conf & 
    udhcpc -i wlan0
    sleep 2
fi
#TODO find canal

################################################
#            Ap part
################################################
ssid_ap=$(uci get bridgebox.wifi-ap.ssid)
key_ap=$(uci get bridgebox.wifi-ap.key)
enabled_ap=$(uci get bridgebox.wifi-ap.enabled)


if [ "$enabled_sta" = "1" ]; then
    #TODO edit /etc/hotapd.conf (ssid + key + canal)
    hostapd /etc/hostapd.conf >/var/log/hostapd  &
fi
