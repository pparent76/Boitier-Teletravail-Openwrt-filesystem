#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh
#####################################################################
#
#               Calcul des variables  
#
#####################################################################
client_mode=$(cat /tmp/bb/client/mode)
client_vpn_mode=$(cat cat /tmp/bb/client/vpn-mode)

case "$client_mode" in
        "offline")
            tpl_client_mode_icon="pause";
            tpl_display_offline="none"; 
            tpl_display_entreprise="inline-block";  
            tpl_display_local="inline-block";
            tpl_display_captive="none"
            tpl_client_mode=$(translate_inline "Hors-ligne" )
            ;;
        "local")
            tpl_client_mode_icon="id-card";
            tpl_display_offline="inline-block";
            tpl_display_entreprise="inline-block";
            tpl_display_local="none";   
            tpl_display_captive="inline-block"
            tpl_client_mode=$(translate_inline "Portail captif" );         
            ;;        
        "entreprise")
            tpl_client_mode_icon="users";
            tpl_display_offline="inline-block";
            tpl_display_entreprise="none";  
            tpl_display_local="inline-block"; 
            tpl_display_captive="none"            
            tpl_client_mode=$(translate_inline "Entreprise" )
            ;;                  
esac  


$tpl_client_mode=$(translate_inline "tpl_client_mode" )

clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

if [ "$client_mode" = "entreprise" ] && [ "$client_vpn_mode" = "tor" ]; then
    tpl_display_warning_client="block"
else
    tpl_display_warning_client="none"
fi

etatinternet=$(cat cat /tmp/bb/internet/internet)

if [ "$etatinternet" = "OK" ]; then
    tpl_internet_text="OK"
    tpl_internet_color="green"
    tpl_display_local="none"; 
    tpl_display_captive="none";
fi

if [ "$etatinternet" = "WARNING" ]; then
    tpl_internet_text=$(translate_inline "Partiel")
    tpl_internet_color="orange"    
fi

if [ "$etatinternet" = "KO" ]; then
    tpl_internet_text="KO"
    tpl_internet_color="red"    
    tpl_display_entreprise="none";      
fi
ipeth0=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1| tr -d '\n')
ipwlan0=$(ifconfig wlan0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1| tr -d '\n')

if [ "$ipeth0" = "" ]&& [ "$ipwlan0" = "" ]; then
    tpl_display_local="none"
    tpl_display_captive="none"
fi

aserverid=$(uci get bridgebox.client.server_id )
aserverpubkey=$(uci get bridgebox.client.serverpubkey )
avpnaddress=$(uci get bridgebox.client.vpnaddress )
if [ "$aserverid" = "" ]|| [ "$aserverpubkey" = "" ]|| [ "$avpnaddress" = "" ]; then
    tpl_display_warning_appaire="block"
    tpl_display_entreprise="none"
else
    tpl_display_warning_appaire="none"
fi

tpl_url_captive=$(uci set bridgebox.advanced.portaldetecturl)




tpl_uptime=$(uptime | tr "," " " | cut -f4-6 -d" " | sed "s/day/$(translate_inline "jour")/g");
echo $tpl_uptime | grep : > /dev/null;
if [ $? = 1 ]; then
	tpl_uptime=$(echo "$tpl_uptime");
else
	tpl_uptime=$(echo "$tpl_uptime $(translate_inline "heure(s)") ");
fi

tpl_box_id=$(sudo /usr/bin/get-id)

serverok=1;
torstate=$(cat /tmp/bb/internet/tor)
porttype=$(cat /tmp/bb/server/port-type)
sudo /usr/bin/wg | grep 1194 >/dev/null 2>&1
wg1024=$?

if [ "$torstate" != "OK" ]; then
    serverok=0;
fi

if [ "$porttype" != "direct" ]&& [ "$porttype" != "stun" ]; then
    serverok=0;
fi

if [ "$wg1024" -ne "0" ]; then
    serverok=0;
fi

if [ "$serverok" -ne "1" ]; then
 tpl_server_state="KO"
 tpl_server_color="red"
else
 tpl_server_state="OK"
 tpl_server_color="green" 
fi



tpl_port1=$(uci get bridgebox.advanced.server_port)
tpl_port2=$(uci get bridgebox.advanced.server_port_backup1)
tpl_port3=$(uci get bridgebox.advanced.server_port_backup2)
tpl_port4=$(uci get bridgebox.advanced.server_port_backup3)

tpl_ippublique=$(cat /tmp/bb/server/ip)

tpl_maclocale=$(ifconfig eth0 | grep HWaddr | awk '{print $5}')
tpl_iplocale=$(ifconfig br-wan | grep inet | awk '{print $2}' | cut  -d: -f2)

if [ "$porttype" != "direct" ]; then
    tpl_display_warning_server="block"
else
    tpl_display_warning_server="none"
fi


if [ "$tpl_display_entreprise" = "none" ]&&  [ "$tpl_display_local" = "none" ]&&  [ "$tpl_display_captive" = "none" ]; then
    tpl_display_action="none";
else
    tpl_display_action="inline-block"
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
page=$( inject_var "$page" ~tpl_active_acceuil "active")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "")
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
    page=$(cat /site/template/home-server.html)
else
    page=$(cat /site/template/home-client.html)
fi
page=$( translate_page_home "$page" )
page=$( inject_var "$page" ~tpl_client_mode "$tpl_client_mode")
page=$( inject_var "$page" ~tpl_client2_mode_icon "$tpl_client_mode_icon")
page=$( inject_var "$page" ~tpl_internet_text "$tpl_internet_text")
page=$( inject_var "$page" ~tpl_internet_color "$tpl_internet_color")
page=$( inject_var "$page" ~tpl_box_id "$tpl_box_id")
page=$( inject_var "$page" ~tpl_uptime "$tpl_uptime")
page=$( inject_var "$page" ~tpl_server_state "$tpl_server_state")
page=$( inject_var "$page" ~tpl_server_color "$tpl_server_color")
page=$( inject_var "$page" ~tpl_port1 "$tpl_port1")
page=$( inject_var "$page" ~tpl_port2 "$tpl_port2")
page=$( inject_var "$page" ~tpl_port3 "$tpl_port3")
page=$( inject_var "$page" ~tpl_port4 "$tpl_port4")
page=$( inject_var "$page" ~tpl_ippublique "$tpl_ippublique")
page=$( inject_var "$page" ~tpl_iplocale "$tpl_iplocale")
page=$( inject_var "$page" ~tpl_maclocale "$tpl_maclocale")
page=$( inject_var "$page" ~tpl_display_warning_server "$tpl_display_warning_server")
page=$( inject_var "$page" ~tpl_display_offline "$tpl_display_offline")
page=$( inject_var "$page" ~tpl_display_entreprise "$tpl_display_entreprise")
page=$( inject_var "$page" ~tpl_display_local "$tpl_display_local")
page=$( inject_var "$page" ~tpl_display_warning_client "$tpl_display_warning_client")
page=$( inject_var "$page" ~tpl_display_action "$tpl_display_action")
page=$( inject_var "$page" ~tpl_display_captive "$tpl_display_captive")
page=$( inject_var "$page" ~tpl_display_warning_appaire "$tpl_display_warning_appaire")
page=$( inject_var "$page" ~tpl_url_captive "$tpl_url_captive")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
