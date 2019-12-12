#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

#####################################################################
#
#               Calcul des variables  
#
#####################################################################
clientservermode=$(uci get bridgebox.general.mode)

tpl_ip_color="aqua"
tpl_ip_wlan=$(ifconfig wlan0| grep "inet addr"  | awk -F" " '{print $2}' | sed -e 's/addr://g')
if [ "$tpl_ip_wlan" = "" ]; then
    tpl_ip_wlan=$(translate_inline "(Pas d'IP)");
    tpl_ip_color="grey"
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

if [ "$(uci get bridgebox.wifi_sta.hidden)" = "1" ]; then
    tpl_checked_hidden="checked"
else
    tpl_checked_hidden=""
fi

enctype_sta=$(uci get bridgebox.wifi_sta.enctype)

    case $enctype_sta in
        "open")
            tpl_selected_none="selected "
        ;;
        "wep-passphrase")
           tpl_selected_WEPpass="selected "           
        ;;
        "wep-hex")
           tpl_selected_WEPhex="selected "           
        ;;        
        "wpa")
            tpl_selected_WPA="selected"
        ;;    
    esac
    
sudo /usr/sbin/wpa_cli status | grep wpa_state | grep COMPLETED >/dev/null 2>&1
if [ "$?" -eq "0" ]; then
    tpl_wifi_client_connected_color="green"
    tpl_wifi_client_connected_text=$(translate_inline "Connecté au réseau wifi")
else
    tpl_wifi_client_connected_color="red"
    tpl_wifi_client_connected_text=$(translate_inline "Déconnecté du réseau wifi")    
fi

pidof hostapd  >/dev/null 2>&1
if [ "$?" -eq "0" ]; then
    tpl_wifi_ap_state_color="green"
    tpl_wifi_ap_state_text=$(translate_inline "En cours d'émission.")   
else
    tpl_wifi_ap_state_color="red"
    tpl_wifi_ap_state_text=$(translate_inline "Pas d'émission wifi.")     
fi

sudo /scripts_bb/test_wlan0_connectivity.sh
if [ "$?" -eq "0" ]; then
    tpl_wifi_client_internet_color="green"
    tpl_wifi_client_internet_text=$(translate_inline "Connecté à Internet.")    
else
    tpl_wifi_client_internet_color="red"
    tpl_wifi_client_internet_text=$(translate_inline "Pas de connection à Internet.")     
fi

#Variable Client/sereveur
clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

#####################################################################
#
#               Generation du html   
#
#####################################################################
inject_var() {
	echo $1 | sed -e "s#$2#$3#g"
}

clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_display_appairage="block"
    tpl_display_wifi="none"
else
    tpl_display_appairage="none"
    tpl_display_wifi="block"
fi

########################################################
#			Header
########################################################
page=$(cat /site/template/header.html)
page=$( translate_header "$page" )
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "active")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "")
page=$( inject_var "$page" ~tpl_clientserver_mode "$tpl_clientserver_mode")
page=$( inject_var "$page" ~tpl_display_appairage "$tpl_display_appairage")
page=$( inject_var "$page" ~tpl_display_wifi "$tpl_display_wifi")
echo $page;

########################################################
#			page
########################################################
if [ "$clientservermode" = "server" ]; then
    page=$(cat /site/template/wifi-server.html)
else
    page=$(cat /site/template/wifi.html)
fi
    page=$( translate_page_wifi "$page" )
    page=$( inject_var "$page" ~tpl_ip_wlan "$tpl_ip_wlan")
    page=$( inject_var "$page" ~tpl_client_ssid "$tpl_client_ssid")
    page=$( inject_var "$page" ~tpl_client_key "$tpl_client_key")
    page=$( inject_var "$page" ~tpl_ap_ssid "$tpl_ap_ssid")
    page=$( inject_var "$page" ~tpl_ap_key "$tpl_ap_key")
    page=$( inject_var "$page" ~tpl_check_active_ap "$tpl_check_active_ap")
    page=$( inject_var "$page" ~tpl_check_active_client "$tpl_check_active_client")
    page=$( inject_var "$page" ~tpl_checked_hidden "$tpl_checked_hidden")
    page=$( inject_var "$page" ~tpl_selected_none "$tpl_selected_none")
    page=$( inject_var "$page" ~tpl_selected_WPA "$tpl_selected_WPA")
    page=$( inject_var "$page" ~tpl_selected_WEPpass "$tpl_selected_WEPpass")
    page=$( inject_var "$page" ~tpl_selected_WEPhex "$tpl_selected_WEPhex")
    page=$( inject_var "$page" ~tpl_wifi_client_connected_color "$tpl_wifi_client_connected_color")
    page=$( inject_var "$page" ~tpl_wifi_client_connected_text "$tpl_wifi_client_connected_text")
    page=$( inject_var "$page" ~tpl_wifi_ap_state_color "$tpl_wifi_ap_state_color")
    page=$( inject_var "$page" ~tpl_wifi_ap_state_text "$tpl_wifi_ap_state_text")
    page=$( inject_var "$page" ~tpl_wifi_client_internet_color "$tpl_wifi_client_internet_color")
    page=$( inject_var "$page" ~tpl_wifi_client_internet_text "$tpl_wifi_client_internet_text")
    page=$( inject_var "$page" ~tpl_ip_color "$tpl_ip_color")    





echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
