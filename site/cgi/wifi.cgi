#!/bin/sh
echo "Content-type: text/html"
echo ""

#####################################################################
#
#               Calcul des variables  
#
#####################################################################
tpl_ip_wlan=$(ifconfig wlan0| grep "inet addr"  | awk -F" " '{print $2}' | sed -e 's/addr://g')
if [ "$tpl_ip_wlan" = "" ]; then
    tpl_ip_wlan="Pas d'IP";
fi

tpl_client_ssid=$(uci get bridgebox.wifi_sta.ssid)
tpl_client_key=$(uci get bridgebox.wifi_sta.key)
tpl_ap_ssid=$(uci get bridgebox.wifi_ap.ssid)
tpl_ap_key=$(uci get bridgebox.wifi_ap.key)

if [ "$(uci get bridgebox.wifi_ap.enabled)" = "1" ]; then
    tpl_check_active_ap="checked"
else
    tpl_check_active_ap=""
fi

if [ "$(uci get bridgebox.wifi_sta.enabled)" = "1" ]; then
    tpl_check_active_client="checked"
else
    tpl_check_active_client=""
fi

#####################################################################
#
#               Generation du html   
#
#####################################################################
inject_var() {
	echo $1 | sed -e "s#$2#$3#g"
}

########################################################
#			Header
########################################################
page=$(cat /site/template/header.html)
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/wifi.html)
page=$( inject_var "$page" ~tpl_ip_wlan "$tpl_ip_wlan")
page=$( inject_var "$page" ~tpl_client_ssid "$tpl_client_ssid")
page=$( inject_var "$page" ~tpl_client_key "$tpl_client_key")
page=$( inject_var "$page" ~tpl_ap_ssid "$tpl_ap_ssid")
page=$( inject_var "$page" ~tpl_ap_key "$tpl_ap_key")
page=$( inject_var "$page" ~tpl_check_active_ap "$tpl_check_active_ap")
page=$( inject_var "$page" ~tpl_check_active_client "$tpl_check_active_client")

echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
