#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<!--"

. /site/traduc/traduc.sh


tpl_result="success"
tpl_title=$( translate_inline_recup "Veuillez patienter")
tpl_text=$( translate_inline_recup "<b>Mise à jour du firmware. (Environ 5 minutes)")
tpl_url_refresh="/cgi/home.cgi"
tpl_time_refresh="300"
tpl_icon="fa-rotate-right fa-spin"


clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

echo "-->"

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


sudo /bin/tar -zcvf /tmp/test.tar.gz  /etc/server-codes /etc/config/bridgebox /etc/desappaire /root/publickey /root/privatekey /tor/ >/dev/null 2>&1
if [ -f /tmp/test.tar.gz ]; then
(sleep 3 ;sudo /sbin/sysupgrade -f /tmp/test.tar.gz /tmp/firmware-ok.bin )  >/dev/null 2>&1 & 
fi

exec >&-
exec 2>&-
