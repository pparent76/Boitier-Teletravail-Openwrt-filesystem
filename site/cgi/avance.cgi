#!/bin/sh
echo "Content-type: text/html"
echo ""

#####################################################################
#
#               Calcul des variables  
#
#####################################################################
tpl_client_mode=$(cat /tmp/bb/client/mode)


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


page=$( inject_var "$page" ~tpl_box_id "$tpl_box_id")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
 
