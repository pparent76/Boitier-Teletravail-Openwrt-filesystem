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



(sleep 3 ;sudo /sbin/sysupgrade -n /tmp/firmware-ok.bin )  >/dev/null 2>&1 & 
exec >&-
exec 2>&-
