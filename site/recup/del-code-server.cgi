#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title=$( translate_inline_recup "Mise à jour de la configuration")
tpl_text=$( translate_inline_recup "Les codes d'accès ont été modifiés")
tpl_url_refresh="/cgi/code.cgi"
tpl_time_refresh="3"
tpl_icon="fa-times"


line=$(sed -n "${numero}p" < /etc/server-codes)
clefl=$(echo "$line" | tr '#' '\n' | head -n 2 | tail -n 1 | tr '\n' ' ' | sed "s/ //g")  
echo "$clefl" >> /etc/desappaire
sudo /bin/sed  -i "${numero}d"  /etc/server-codes

#Variable Client/serveur    
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

sudo /scripts_bb/server/vpn.sh 2> /dev/null > /dev/null &
exec >&-
exec 2>&-

exit 0
 
