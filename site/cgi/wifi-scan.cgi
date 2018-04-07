#!/bin/sh
echo "Content-type: text/html"
echo ""

inject_var() {
	echo $1 | sed -e "s#$2#$3#g"
}


#####################################################################
#
#               Calcul des variables  
#
#####################################################################

sudo /usr/bin/iwinfo wlan0 scan | grep 'ESSID\|Signal: \|Encryption: '  > /tmp/wifi-scan
tpl_tab_rows=""

while IFS='' read -r ssid || [[ -n "$ssid" ]]; do
    read -r signal;  read -r encryption;
    ssid=$(echo $ssid | sed -e "s/ESSID: //g" | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/')
    encryption=$(echo $encryption | sed -e "s/Encryption: //g")
    encryption=$(echo $encryption | sed -e "s/none/Ouvert/g")    
    
    ligne=$(cat /site/template/tab_line/wifi-scan-line.html)
    

    ligne=$( inject_var "$ligne" ~tpl_row_encname "$encryption ")
    ligne=$( inject_var "$ligne" ~tpl_row_ssid "$ssid")
    
    #Ouvert
    echo $encryption | grep Ouvert >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        ligne=$( inject_var "$ligne" ~tpl_end_url "\&enctype=open")
    fi
    
    #WPA
    echo $encryption | grep WPA >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        ligne=$( inject_var "$ligne" ~tpl_end_url "\&enctype=wpa")
    fi    
    
    #WEP
    echo $encryption | grep WEP >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        ligne=$( inject_var "$ligne" ~tpl_end_url "\&enctype=wep-hex")
    fi        
    
    tpl_tab_rows="$tpl_tab_rows $ligne" ;
done < /tmp/wifi-scan



#####################################################################
#
#               Generation du html   
#
#####################################################################

########################################################
#			Header
########################################################
page=$(cat /site/template/header.html)
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "active")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "")
echo $page;

########################################################
#			page
########################################################
page=$(cat /site/template/wifi-scan.html)
page=$( inject_var "$page" ~tpl_tab_rows "$tpl_tab_rows")
echo $page;

#echo $tpl_tab_rows

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
