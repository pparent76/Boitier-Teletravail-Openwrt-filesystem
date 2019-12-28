#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title=$( translate_inline_recup "Mise à jour de la configuration" )
tpl_text=$( translate_inline_recup "Les paramètres avancés généraux ont été mis à jour!")
tpl_url_refresh="/cgi/avance.cgi"
tpl_time_refresh="3"
tpl_icon="fa-check"

ok=1

    sudo /sbin/uci  set bridgebox.advanced.stun1=$stun1
    sudo /sbin/uci  set bridgebox.advanced.stun2=$stun2
    sudo /sbin/uci  set bridgebox.advanced.stun3=$stun3   
    
    sudo /sbin/uci  set bridgebox.advanced.stunport1=$stun_port1
    sudo /sbin/uci  set bridgebox.advanced.stunport2=$stun_port2
    sudo /sbin/uci  set bridgebox.advanced.stunport3=$stun_port3  
    
    sudo /sbin/uci  set bridgebox.advanced.torproxy=$torproxy    
    sudo /sbin/uci  set bridgebox.advanced.torproxy_automaj_git=$automajtorgit
 
    sudo /sbin/uci  set bridgebox.advanced.ippingtest1=$ping1 
    sudo /sbin/uci  set bridgebox.advanced.ippingtest2=$ping2 
    sudo /sbin/uci  set bridgebox.advanced.ippingtest3=$ping3
    
    sudo /sbin/uci  set bridgebox.advanced.portaldetecturl=$captiveurl    
    
    if [ -z "$automajtoractivated" ]; then
        sudo /sbin/uci set bridgebox.advanced.torproxy_automaj_activated="0"
    else
        sudo /sbin/uci set bridgebox.advanced.torproxy_automaj_activated="1"
    fi

    sudo /sbin/uci  commit


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
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "active")
page=$( inject_var "$page" ~tpl_clientserver_mode "$tpl_clientserver_mode")
page=$( inject_var "$page" ~tpl_display_wifi "$tpl_display_wifi")
page=$( inject_var "$page" ~tpl_clientserver_mode "$tpl_clientserver_mode")
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/recup.html)
page=$( inject_var "$page" ~tpl_result "$tpl_result")
page=$( inject_var "$page" ~tpl_title "$tpl_title")
page=$( inject_var "$page" ~tpl_text "$tpl_text")
page=$( inject_var "$page" ~tpl_url_refresh "$tpl_url_refresh")
page=$( inject_var "$page" ~tpl_time_refresh "$tpl_time_refresh")
page=$( inject_var "$page" ~tpl_icon "$tpl_icon")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;

exit 0
