#!/bin/sh
echo "Content-type: text/html"
echo ""

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title="Mise à jour de la configuration"
tpl_text="Les paramètres avancés du serveur ont été mis à jour!"
tpl_url_refresh="/cgi/avance.cgi"
tpl_time_refresh="3"
tpl_icon="fa-check"

ok=1

    sudo /sbin/uci  set bridgebox.advanced.server_port=$port1
    sudo /sbin/uci  set bridgebox.advanced.server_port_backup1=$port2
    sudo /sbin/uci  set bridgebox.advanced.server_port_backup2=$port3
    sudo /sbin/uci  set bridgebox.advanced.server_port_backup3=$port4    
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
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "active")
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

exec >&-
exec 2>&-

if [ "$ok" -eq "1" ];  then
    (sleep 2; sudo /scripts_bb/wifi.sh >/dev/null 2>&1) &
fi
exit 0
