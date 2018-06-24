#!/bin/sh
echo "Content-type: text/html"
echo ""

. ./post.sh
cgi_getvars BOTH ALL

requestedmode=$(cat /tmp/web-requested-mode)
previousmode=$(cat /tmp/web-previous-mode)
currentmode=$(cat /tmp/bb/client/mode)

tpl_result="info"
tpl_title="Changement de mode de fonctionnement"
tpl_text="Passage en mode <b>$requestedmode</b>."
tpl_url_refresh="/recup/check-change-mode.cgi"
tpl_time_refresh="3"
tpl_icon="fa-rotate-right fa-spin"

ps |  grep -v grep | grep openvpn.sh > /dev/null 2>&1 ;
entreprise=$?

ps |  grep -v grep | grep captive-por  > /dev/null 2>&1 ;
local=$?

ps |  grep -v grep |grep get-offline.sh  > /dev/null 2>&1;
offline=$?

needtoreconnect=0;
if [ "$requestedmode" = "entreprise" ]&& [ "$previousmode" != "entreprise" ]; then
    needtoreconnect=1;
fi
if [ "$requestedmode" != "entreprise" ]&& [ "$previousmode" = "entreprise" ]; then
    needtoreconnect=1;
fi

isdone=0;
if [ "$entreprise" -ne "0" ]&& [ "$local" -ne "0" ] && [ "$offline" -ne "0" ] ; then
    if [ "$requestedmode" != "$currentmode"  ]; then
        tpl_url_refresh="/cgi/home.cgi"
        tpl_icon="fa-times" 
        tpl_result="error"
        tpl_time_refresh="6"   
        tpl_text="Erreur: n'a pas put passé en mode $requestedmode, retour au mode $currentmode"
    else
        tpl_url_refresh="/cgi/home.cgi"
        tpl_title="Changement de mode de fonctionnement réussit"
        tpl_icon="fa-check" 
        tpl_text="Passage en mode <b>$requestedmode</b> réussit!"
        tpl_result="success"   
        if [ "$needtoreconnect" -eq "1" ]; then
                    tpl_result="success"
                    tpl_time_refresh="60"
        fi
        isdone=1;
    fi
fi

if [ "$needtoreconnect" -eq "1" ]; then
if [ "$isdone" -eq "1" ]; then
    tpl_text=$(echo "$tpl_text<br><br> <h4> <u>Attention:</u> Il est nécessaire de déconnecter et reconnecter votre appareil au boîtier afin de récupérer l’adresse IP correspondante à votre réseau.</h4>")
else
    tpl_text=$(echo "$tpl_text<br><br> <h4> <u>Attention:</u> Il sera nécessaire de déconnecter et reconnecter votre appareil au boîtier afin de récupérer l’adresse IP correspondante à votre réseau.</h4>")
fi

fi

#Variable Client/serveur    
clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode="Serveur"
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
page=$( inject_var "$page" ~tpl_active_acceuil "active")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "")
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
 
