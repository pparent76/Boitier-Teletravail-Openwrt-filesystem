#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<!--"

tpl_result="success"
tpl_title="Veuillez patienter"
tpl_icon="fa-rotate-right fa-spin"
tpl_url_refresh="/recup/redemarrer.cgi"
tpl_time_refresh="3"


clientservermode=$(uci get bridgebox.general.mode)

if [ "$clientservermode" = "server" ]; then
    sudo /sbin/uci set bridgebox.general.mode=client
else
    sudo /sbin/uci set bridgebox.general.mode=server
fi

sudo /sbin/uci commit

clientservermode=$(uci get bridgebox.general.mode)

if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode="serveur"
else
    tpl_clientserver_mode="client"
fi

tpl_text="Passage en <b>mode $tpl_clientserver_mode</b>"

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


