#!/bin/sh

echo "Content-type: text/html"
echo ""

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

#########################################################
#           Page
#########################################################
echo '	<body style="background-color: #ecf0f5;">
		<div class="col-md-4"></div>
            <div class="col-md-6" style="margin-top:20%"> 
             <div class="box  box-success">
             <div class="box-body chat" id="chat-box">'
params=$(cat /advertise/index.html | sed "s/BEGINADVERTISE//g" |  sed "s/ENDADVERTISE//g")
echo "<b>Etat tor:</b> $torstate <br>"
echo "<b>Mode:</b> $(echo $params | awk '{print $1;}' ) <br>"
echo "<b>Process:</b> $openvpncount/2 <br>"
echo "<b>IP publique:</b> $(echo $params | awk '{print $2;}' ) <br>"
echo "<b>Port publique:</b> $(echo $params | awk '{print $3;}' ) <br>"


echo '            <div><div><div>
     </body>       '

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
