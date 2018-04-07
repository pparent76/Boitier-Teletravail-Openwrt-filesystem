#!/bin/sh
echo "Content-type: text/html"
echo ""

#####################################################################
#
#               Calcul des variables  
#
#####################################################################

. ../recup/post.sh
cgi_getvars BOTH ALL

tpl_client_ssid=$ssid

    case $enctype in
        "open")
            tpl_selected_none="selected "
        ;;
        "wep-passphrase")
           tpl_selected_WEPpass="selected "           
        ;;
        "wep-hex")
           tpl_selected_WEPhex="selected "           
        ;;        
        "wpa")
            tpl_selected_WPA="selected"
        ;;    
    esac


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
page=$( inject_var "$page" ~tpl_active_wifi "active")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "")
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/wifi-config-one-network.html)

page=$( inject_var "$page" ~tpl_client_ssid "$tpl_client_ssid")
page=$( inject_var "$page" ~tpl_selected_none "$tpl_selected_none")
page=$( inject_var "$page" ~tpl_selected_WPA "$tpl_selected_WPA")
page=$( inject_var "$page" ~tpl_selected_WEPpass "$tpl_selected_WEPpass")
page=$( inject_var "$page" ~tpl_selected_WEPhex "$tpl_selected_WEPhex")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
