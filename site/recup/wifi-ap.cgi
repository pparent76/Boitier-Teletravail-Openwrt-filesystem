#!/bin/sh
echo "Content-type: text/html"
echo ""

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title="Mise à jour Configuration"
tpl_text="Les paramètres du réseau wifi émis ont été mis à jour. Le wifi va redémarrer!"
tpl_url_refresh="/cgi/wifi.cgi"
tpl_time_refresh="3"

#Todo vérifier la longueur du SSID et de la clef

sudo /sbin/uci set bridgebox.wifi_ap.ssid=$ssid
sudo /sbin/uci set bridgebox.wifi_ap.key=$pass

if [ -z "$active_wifi_ap" ]; then
    sudo /sbin/uci set bridgebox.wifi_ap.enabled="0"
else
    sudo /sbin/uci set bridgebox.wifi_ap.enabled="1"
fi

sudo /sbin/uci  commit
    
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
