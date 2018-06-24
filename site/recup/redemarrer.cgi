#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<!--"

tpl_result="success"
tpl_title="Veuillez patienter"
tpl_text="<b>Redémarrage du Boitier. (Environ 2 minutes)"
tpl_url_refresh="/cgi/home.cgi"
tpl_time_refresh="120"
tpl_icon="fa-rotate-right fa-spin"



echo "-->"

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



(sleep 3 ;sudo /sbin/reboot )  >/dev/null 2>&1 & 
exec >&-
exec 2>&-
