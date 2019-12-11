#!/bin/sh

echo "Content-type: text/html"
echo ""


. /site/traduc/traduc.sh
#####################################################################
#
#               Calcul des variables  
#
#####################################################################

clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

torstate=$(cat /tmp/bb/internet/tor)
openvpncount=$(ps |  grep  "openvpn /etc/openvpn/" | grep -v grep | wc -l)

#####################################################################
#
#               Generation du html   
#
#####################################################################
inject_var() {
	echo $1 | sed -e "s#$2#$3#g"
}


clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_display_appairage="block"
    tpl_display_wifi="none"
else
    tpl_display_appairage="none"
    tpl_display_appairage="block"
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


sudo /usr/bin/wg | grep 1194 >/dev/null 2>&1
if [ "$?" -eq "0" ]; then
    processcom="Wg OK"
else
    processcom="Wg NOK"
fi
#########################################################
#           Page
#########################################################
echo '	<body style="background-color: #ecf0f5;">
		<div class="col-md-4"></div>
            <div class="col-md-6" style="margin-top:20%"> 
             <div class="box  box-success">
             <div class="box-body chat" id="chat-box">'
params=$(cat /advertise/index.html | sed "s/BEGINADVERTISE//g" |  sed "s/ENDADVERTISE//g")
translate_page_details "<b>Etat tor:</b> $torstate <br>" 
translate_page_details"<b>Mode:</b> $(echo $params | awk '{print $1;}' ) <br>"
translate_page_details "<b>Process:</b> $processcom <br>"
translate_page_details "<b>IP publique:</b> $(echo $params | awk '{print $2;}' ) <br>"
translate_page_details "<b>Port publique:</b> $(echo $params | awk '{print $3;}' ) <br>"


echo '            <div><div><div>
     </body>       '

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
