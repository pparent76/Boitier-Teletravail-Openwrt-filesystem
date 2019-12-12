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
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

etatinternet=$(cat cat /tmp/bb/internet/internet)

if [ "$etatinternet" = "OK" ]; then
    tpl_internet_text="OK"
    tpl_internet_color="green"
fi

if [ "$etatinternet" = "WARNING" ]; then
    tpl_internet_text="Partiel"
    tpl_internet_color="orange"    
fi

if [ "$etatinternet" = "KO" ]; then
    tpl_internet_text="KO"
    tpl_internet_color="red"     
fi

torstate=$(cat /tmp/bb/internet/tor)

if [ "$torstate" = "OK" ]; then
tpl_tor_state="OK"
tpl_tor_color="green"
else
tpl_tor_state="KO"
tpl_tor_color="red"
fi

pingstate=$(cat /tmp/bb/internet/ping)

if [ "$pingstate" != "KO" ]; then
tpl_ping_state="OK ($pingstate)"
tpl_ping_color="green"
else
tpl_ping_state="KO"
tpl_ping_color="red"
fi

stunstate=$(cat /tmp/bb/internet/stun)

if [ "$stunstate" != "KO" ]; then
tpl_stun_state="OK"
tpl_stun_color="green"
else
tpl_stun_state="KO"
tpl_stun_color="red"
fi

udpstate=$(cat /tmp/bb/internet/udp-port)

if [ "$udpstate" != "KO" ]; then
tpl_udp_state="OK"
tpl_udp_color="green"
else
tpl_udp_state="KO"
tpl_udp_color="red"
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

page=$(cat /site/template/check-internet.html)
page=$( translate_page_details "$page" )
page=$( inject_var "$page" ~tpl_internet_text "$tpl_internet_text")
page=$( inject_var "$page" ~tpl_internet_color "$tpl_internet_color")
page=$( inject_var "$page" ~tpl_tor_state "$tpl_tor_state")
page=$( inject_var "$page" ~tpl_ping_state "$tpl_ping_state")
page=$( inject_var "$page" ~tpl_tor_color "$tpl_tor_color")
page=$( inject_var "$page" ~tpl_ping_color "$tpl_ping_color")
page=$( inject_var "$page" ~tpl_stun_color "$tpl_stun_color")
page=$( inject_var "$page" ~tpl_stun_state "$tpl_stun_state")
page=$( inject_var "$page" ~tpl_udp_color "$tpl_udp_color")
page=$( inject_var "$page" ~tpl_udp_state "$tpl_udp_state")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
 
