#!/bin/sh
echo "Content-type: text/html"
echo ""

. ./post.sh
cgi_getvars BOTH ALL

tpl_result="success"
tpl_title="Mise à jour de la configuration"
tpl_text="Les codes d'accès ont été modifiés"
tpl_url_refresh="/cgi/code.cgi"
tpl_time_refresh="3"
tpl_icon="fa-check"

p_hote=$(uci get bridgebox.client.server_id)
p_code=$(uci get bridgebox.client.password)
p_commentaire=$(uci get bridgebox.client.comment)
commentaire=$(echo "$commentaire" | sed -e "s/[!@#\$%^&~*()\"\\\'\(\)\;\/\`\:\<\>]//g")
    
if [ "$p_code" = "$code" ]&& [ "$p_hote" = "$hote" ]&& [ "$p_commentaire" = "$commentaire" ]; then
    tpl_text="Les codes d'accès envoyés sont les même qu'avant!"
else
    ok=1
   echo "$hote" | egrep -q '^[a-z0-9]{16}$'
    if [ "$?" -ne "0" ]; then
        tpl_result="error"
        tpl_text="Mauvais hote"
        ok=0
    fi
   echo "$code" | egrep -q '^[a-zA-Z0-9]{8,127}$'
    if [ "$?" -ne "0" ]; then
        tpl_result="error"
        tpl_text="Le code doit contenir uniquement de lettres (majuscules ou minuscules) et Chiffres.<br> Il doit avoir un taille entre 8 et 127 caractères."
        ok=0
    fi  
    if [ "$ok" -eq "1" ]; then
      sudo /sbin/uci set bridgebox.client.server_id="$hote"
      sudo /sbin/uci  set bridgebox.client.password="$code"    
      sudo /sbin/uci  set bridgebox.client.comment="$commentaire"   
      echo "$hote#$code#$commentaire#" >> /etc/client-code-history
      sudo /sbin/uci  commit
    fi
fi

#Variable Client/serveur    
clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode="Serveur"
else
    tpl_clientserver_mode="Client"
fi

#   
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
page=$( inject_var "$page" ~tpl_icon "$tpl_icon")
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;

exit 0
 
