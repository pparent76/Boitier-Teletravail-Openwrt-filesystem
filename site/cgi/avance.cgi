#!/bin/sh
echo "Content-type: text/html"
echo ""

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


clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode="Serveur"
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


tpl_box_id=$(sudo /usr/bin/get-id)


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
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "active")
page=$( inject_var "$page" ~tpl_clientserver_mode "$tpl_clientserver_mode")
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/avance.html)

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

page=$( inject_var "$page" ~tpl_torproxy "$tpl_torproxy")
page=$( inject_var "$page" ~tpl_box_id "$tpl_box_id")
page=$( inject_var "$page" ~tpl_check_autostart "$tpl_check_autostart")

page=$( inject_var "$page" ~tpl_display_server_inline "$tpl_display_server_inline")
page=$( inject_var "$page" ~tpl_display_client_inline "$tpl_display_client_inline")

page=$( inject_var "$page" ~tpl_display_server_block "$tpl_display_server_block")
page=$( inject_var "$page" ~tpl_display_client_block "$tpl_display_client_block")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
 