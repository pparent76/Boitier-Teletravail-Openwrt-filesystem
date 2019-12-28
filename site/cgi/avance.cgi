#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

#####################################################################
#
#               Calcul des variables  
#
#####################################################################
tpl_client_mode=$(cat /tmp/bb/client/mode)
clientservermode=$(uci get bridgebox.general.mode)

if [ "$clientservermode" = "server" ]; then
tpl_display_server_inline="inline-block" 
tpl_display_client_inline="none" 
tpl_display_server_block="block" 
tpl_display_client_block="none" 
else
tpl_display_client_inline="inline-block" 
tpl_display_server_inline="none"
tpl_display_client_block="block" 
tpl_display_server_block="none"
fi

langue=$(uci get bridgebox.general.langue);4
if [ "$langue" = "en" ]; then
tpl_selected_en="selected"
tpl_selected_fr=""
else
tpl_selected_en=""
tpl_selected_fr="selected"
fi

tpl_port1=$(uci get bridgebox.advanced.server_port)
tpl_port2=$(uci get bridgebox.advanced.server_port_backup1)
tpl_port3=$(uci get bridgebox.advanced.server_port_backup2)
tpl_port4=$(uci get bridgebox.advanced.server_port_backup3)

tpl_stun1=$(uci get bridgebox.advanced.stun1)
tpl_stun2=$(uci get bridgebox.advanced.stun2)
tpl_stun3=$(uci get bridgebox.advanced.stun3)

tpl_stun_port1=$(uci get bridgebox.advanced.stunport1)
tpl_stun_port2=$(uci get bridgebox.advanced.stunport2)
tpl_stun_port3=$(uci get bridgebox.advanced.stunport3)

tpl_torproxy=$(uci get bridgebox.advanced.torproxy)
tpl_torproxy_automaj_git=$(uci get bridgebox.advanced.torproxy_automaj_git)
res=$(uci get bridgebox.advanced.torproxy_automaj_activated)
if [ "$res" -eq "1" ]; then
    tpl_checked_torproxy_automaj_activated="checked"
else
    tpl_checked_torproxy_automaj_activated=""
fi

tpl_captiveurl=$(uci get bridgebox.advanced.portaldetecturl)

tpl_ping1=$(uci get bridgebox.advanced.ippingtest1)
tpl_ping2=$(uci get bridgebox.advanced.ippingtest2)
tpl_ping3=$(uci get bridgebox.advanced.ippingtest3)


clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

tpl_check_autostart="checked"
res=$(uci get bridgebox.advanced.clientautostart)

if [ "$res" -eq "1" ]; then
    tpl_check_autostart="checked"
else
    tpl_check_autostart=""
fi


tpl_box_id=$(cat /sys/class/net/eth0/address)


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
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "active")
page=$( inject_var "$page" ~tpl_display_appairage "$tpl_display_appairage")
page=$( inject_var "$page" ~tpl_display_wifi "$tpl_display_wifi")
page=$( inject_var "$page" ~tpl_clientserver_mode "$tpl_clientserver_mode")
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/avance.html)

page=$( translate_page_avance "$page" )

page=$( inject_var "$page" ~tpl_port1 "$tpl_port1")
page=$( inject_var "$page" ~tpl_port2 "$tpl_port2")
page=$( inject_var "$page" ~tpl_port3 "$tpl_port3")
page=$( inject_var "$page" ~tpl_port4 "$tpl_port4")

page=$( inject_var "$page" ~tpl_stun1 "$tpl_stun1")
page=$( inject_var "$page" ~tpl_stun2 "$tpl_stun2")
page=$( inject_var "$page" ~tpl_stun3 "$tpl_stun3")

page=$( inject_var "$page" ~tpl_stun_port1 "$tpl_stun_port1")
page=$( inject_var "$page" ~tpl_stun_port2 "$tpl_stun_port2")
page=$( inject_var "$page" ~tpl_stun_port3 "$tpl_stun_port3")

page=$( inject_var "$page" ~tpl_checked_torproxy_automaj_activated "$tpl_checked_torproxy_automaj_activated")
page=$( inject_var "$page" ~tpl_torproxy_automaj_git "$tpl_torproxy_automaj_git")
page=$( inject_var "$page" ~tpl_torproxy "$tpl_torproxy")



page=$( inject_var "$page" ~tpl_box_id "$tpl_box_id")
page=$( inject_var "$page" ~tpl_check_autostart "$tpl_check_autostart")

page=$( inject_var "$page" ~tpl_display_server_inline "$tpl_display_server_inline")
page=$( inject_var "$page" ~tpl_display_client_inline "$tpl_display_client_inline")

page=$( inject_var "$page" ~tpl_display_server_block "$tpl_display_server_block")
page=$( inject_var "$page" ~tpl_display_client_block "$tpl_display_client_block")

page=$( inject_var "$page" ~tpl_selected_fr "$tpl_selected_fr")
page=$( inject_var "$page" ~tpl_selected_en "$tpl_selected_en")

page=$( inject_var "$page" ~tpl_captiveurl "$tpl_captiveurl")

page=$( inject_var "$page" ~tpl_ping1 "$tpl_ping1")
page=$( inject_var "$page" ~tpl_ping2 "$tpl_ping2")
page=$( inject_var "$page" ~tpl_ping3 "$tpl_ping3")

echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
 
