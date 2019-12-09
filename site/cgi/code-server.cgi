#!/bin/sh

echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

inject_var() {
	echo $1 | sed -e "s#$2#$3#g"
}

function nstars {
    for i in $(seq $1); do
        echo -n '*'
    done
}

. ../recup/post.sh
cgi_getvars BOTH ALL


clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
else
    tpl_clientserver_mode="Client"
fi

tpl_hote=$(uci get bridgebox.client.server_id)
tpl_code=$(uci get bridgebox.client.password)
tpl_commentaire=$(uci get bridgebox.client.comment)



tpl_history_rows="~tpl_history_row" 

j=1;

if [ "$displaycodes" != "1" ]; then
  tpl_displaycode_visible="block"
  tpl_hidecode_visible="none"  
else
  tpl_displaycode_visible="none"
  tpl_hidecode_visible="block"  
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
 if [ "$line" != "" ]; then 
    hostl=$(sudo /usr/bin/get-id)
    codel=$(echo "$line" | tr '#' '\n' | head -n 1 | tr '\n' ' ' | sed "s/ //g")  
    codedecrypt=$codel;
    if [ "$displaycodes" != "1" ]; then
        codel=$(nstars ${#codel})
    fi
    commentairel=$(echo "$line" | tr '#' '\n' | tail -n 1 | tr '\n' ' ')     
    tpl_history_row=$(cat /site/template/tab_line/code-server.html | tr '\n' ' ' )
    tpl_history_row=$( inject_var "$tpl_history_row" ~tpl_host "$hostl") 
    tpl_history_row=$( inject_var "$tpl_history_row" ~tpl_code "$codel") 
    tpl_history_row=$( inject_var "$tpl_history_row" ~tpl_decryptcode "$codedecrypt")    
    tpl_history_row=$( inject_var "$tpl_history_row" ~tpl_commentaire "$commentairel")    
    tpl_history_row=$( inject_var "$tpl_history_row" ~tpl_count_index "$j")     
    tpl_history_rows=$( inject_var "$tpl_history_rows" ~tpl_history_row "~tpl_history_row $tpl_history_row") 
    j=$(( j+1 ))
  fi
done < /etc/server-codes

tpl_history_rows=$( inject_var "$tpl_history_rows" ~tpl_history_row "")
#####################################################################
#
#               Generation du html   
#
#####################################################################

clientservermode=$(uci get bridgebox.general.mode)
if [ "$clientservermode" = "server" ]; then
    tpl_display_appairage="inline-block"
    tpl_display_wifi="none"
else
    tpl_display_appairage="none"
    tpl_display_wifi="inline-block"
fi

########################################################
#			Header
########################################################
page=$(cat /site/template/header.html)
page=$( translate_header "$page" )
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "active")
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
page=$(cat /site/template/code-server.html)
page=$( translate_page_code "$page" )
page=$( inject_var "$page" ~tpl_code "$tpl_code")
page=$( inject_var "$page" ~tpl_hote "$tpl_hote")
page=$( inject_var "$page" ~tpl_commentaire "$tpl_commentaire")
page=$( inject_var "$page" ~tpl_history_rows "$tpl_history_rows")  
page=$( inject_var "$page" ~tpl_displaycode_visible "$tpl_displaycode_visible") 
page=$( inject_var "$page" ~tpl_hidecode_visible "$tpl_hidecode_visible") 
page=$( inject_var "$page" ~tpl_newline "\%0A") 
page=$( inject_var "$page" ~tpl_etbody "\&body") 
echo $page;

########################################################
#			Footer
########################################################
page=$(cat /site/template/footer.html)
echo $page;
