#!/bin/sh
echo "Content-type: text/html"
echo ""

#####################################################################
#
#               Calcul des variables  
#
#####################################################################
tpl_client_mode=$(cat /tmp/bb/client/mode)

case "$tpl_client_mode" in
        "offline")
            tpl_client_mode_icon="pause";
            ;;
        "local")
            tpl_client_mode_icon="map-marker";
            ;;        
        "entreprise")
            tpl_client_mode_icon="users";
            ;;                  
esac            

clientservermode=$(uci get bridgebox.general.mode)
if [ "clientservermode" = "server" ]; then
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
page=$(cat /site/template/home-client.html)
page=$( inject_var "$page" ~tpl_client_mode "$tpl_client_mode")
page=$( inject_var "$page" ~tpl_client2_mode_icon "$tpl_client_mode_icon")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
