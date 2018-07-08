#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title="Veuillez patienter: Mise à jour de la configuration"
tpl_text="Bravo vous allez pouvoir utiliser le boîtier télétravail!"
tpl_url_refresh="/cgi/home.cgi"
tpl_time_refresh="5"
tpl_icon="fa-rotate-right fa-spin"

if [ "$langue" = "en" ]; then
        sudo /sbin/uci set bridgebox.general.langue="en"
else
        sudo /sbin/uci set bridgebox.general.langue="fr"
fi

clientserver=$(sudo /sbin/uci get bridgebox.general.mode)

if [ "$clientserver" != "$mode" ]; then
        tpl_text="Bravo vous allez pouvoir utiliser le boîtier télétravail après redémarrage!"
        tpl_url_refresh="/recup/redemarrer.cgi"
fi

if [ "$mode" = "server" ]; then
        sudo /sbin/uci set bridgebox.general.mode="server"
else
        sudo /sbin/uci set bridgebox.general.mode="client"
fi
sudo /sbin/uci commit

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
 
