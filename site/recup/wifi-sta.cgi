#!/bin/sh
echo "Content-type: text/html"
echo ""

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title="Mise à jour de la configuration"
tpl_text="Les paramètres du client wifi ont été mis à jour. <b>Le wifi va redémarrer!</b>"
tpl_url_refresh="/cgi/wifi.cgi"
tpl_time_refresh="3"

ok=1

if [ "$ssid" = "" ]; then 
    tpl_result="error"
    tpl_text="Erreur ssid vide!"
    ok=0;
fi

if [ ${#ssid} -gt 32 ]; then 
    tpl_result="error"
    tpl_text="Erreur ssid trop long!"
    ok=0;
fi

if [ "$enctype" = "WPA" ] && [ ${#pass} -gt 63 ]; then 
    tpl_result="error"
    tpl_text="Clef WPA trop longue"
    ok=0;
fi

if [ "$enctype" = "WPA" ] && [ ${#pass} -lt 8 ]; then 
    tpl_result="error"
    tpl_text="Clef WPA trop courte"
    ok=0;
fi

if [ "$enctype" = "WEPhex" ] && [ ${#pass} -ne 10 ] && [ ${#pass} -ne 32 ]; then 
    tpl_result="error"
    tpl_text="Mauvaise taille de clef WEP hexadecimale."
    ok=0;
fi

if [ "$enctype" = "WEPpass" ] && [ ${#pass} -lt 5 ]; then 
    tpl_result="error"
    tpl_text="Clef wep trop courte"
    ok=0;
fi

if [ "$enctype" = "WEPpass" ] && [ ${#pass} -gt 29 ]; then 
    tpl_result="error"
    tpl_text="Clef wep trop longue"
    ok=0;
fi

if [ "$ok" -eq "1" ];  then
    #Todo vérifier la longueur du SSID et de la clef

    sudo /sbin/uci set bridgebox.wifi_sta.ssid="$ssid"
    sudo /sbin/uci set bridgebox.wifi_sta.key="$pass"

    if [ -z "$active_wifi_client" ]; then
        sudo /sbin/uci set bridgebox.wifi_sta.enabled="0"
    else
        sudo /sbin/uci set bridgebox.wifi_sta.enabled="1"
    fi

    if [ -z "$hidden" ]; then
        sudo /sbin/uci set bridgebox.wifi_sta.hidden="0"
    else
        sudo /sbin/uci set bridgebox.wifi_sta.hidden="1"
    fi

    case $enctype in
        "none")
            sudo /sbin/uci set bridgebox.wifi_sta.enctype="open"
        ;;
        "WEPpass")
           sudo /sbin/uci set bridgebox.wifi_sta.enctype="wep-passphrase"           
        ;;
        "WEPhex")
           sudo /sbin/uci set bridgebox.wifi_sta.enctype="wep-hex"     
        ;;        
        "WPA")
            sudo /sbin/uci set bridgebox.wifi_sta.enctype="wpa"
        ;;    
    esac
    
    $enctype
    sudo /sbin/uci  commit
fi

#Variable Client/serveur    
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
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "active")
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

echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;

exec >&-
exec 2>&-

if [ "$ok" -eq "1" ];  then
    (sleep 2; sudo /scripts_bb/wifi.sh >/dev/null 2>&1) &
fi
exit 0
