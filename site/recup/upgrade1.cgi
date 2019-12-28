#!/bin/sh
echo "Content-type: text/html"
echo ""

. /site/traduc/traduc.sh

  rm /tmp/firmware.bin
  rm /tmp/firmware-ok.bin
  #########################################################
  #       Upload file
  #########################################################
  TMPOUT=/tmp/firmware.fir
  cat >$TMPOUT
  
  ###########################################################
  #      Decrypt file
  ###########################################################

   # Get the line count
  LINES=$(wc -l $TMPOUT | cut -d ' ' -f 1)

  # Remove the first four lines
  tail -$((LINES - 4)) $TMPOUT >$TMPOUT.1

  # Remove the last line
  head -$((LINES - 5)) $TMPOUT.1 >$TMPOUT

  # Copy everything but the new last line to a temporary file
  head -$((LINES - 6)) $TMPOUT >$TMPOUT.1

  # Copy the new last line but remove trailing \r\n
  tail -1 $TMPOUT | perl -p -i -e 's/\r\n$//' >>$TMPOUT.1
  
  rm $TMPOUT
  md5sumr=$(md5sum  $TMPOUT.1 |awk '{print $1}')  
  code="YjI5NWU2ODkzNDhlYzJlODY5MGI4NWE4";
  openssl aes-256-cbc -d -pass pass:$code -out $TMPOUT.2 -in $TMPOUT.1 >/tmp/openssl 2>&1 
  mv $TMPOUT.2 $TMPOUT.1


  #########################################################
  #       End of Upload file
  #########################################################  
  
  #split
  dd if=/tmp/firmware.fir.1 of=/tmp/firmware-header count=34 bs=1c  
  dd if=/tmp/firmware.fir.1 of=/tmp/firmware-ver count=7 bs=1c   skip=34
  dd if=/tmp/firmware.fir.1 of=/tmp/firmware.bin bs=41 skip=1
  rm /tmp/firmware.fir.1

  #display variables
  ver=$(cat /tmp/firmware-ver)

  #Check
  sysupgrade -T /tmp/firmware.bin >/dev/null 2>&1
    firmewareok="$?";
  cmp -s /tmp/firmware-header /etc/firmware-header
    headerok="$?";  
        
    
  if [ "$firmewareok" -eq "0" ]&& [ "$headerok" -eq "0" ]; then
    mv /tmp/firmware.bin /tmp/firmware-ok.bin
    
    #
    tpl_result="success"
    tpl_title=$( translate_inline_recup "Mise à jour du firmware" )
    tpl_text="<b>$( translate_inline_recup "Firmware correct!")</b> <br><b>Version:</b> $ver </br> <b>md5sum:</b> $md5sumr </br> <center><a href=\"/recup/upgrade2.cgi\" class=\"btn btn-info btn-sm ad-click-event\">$( translate_inline_recup "Mettre à jour" ) </a></center> "
    tpl_url_refresh="/cgi/avance.cgi"
    tpl_time_refresh="300"
    tpl_icon="fa-refresh"

  else

    tpl_result="error"
    tpl_icon="fa-times"
    tpl_title=$( translate_inline_recup "Mauvais firmware" )
    tpl_text=$( translate_inline_recup "Le fichier envoyé n'est pas un fichier de firmware valable!")
    tpl_url_refresh="/cgi/avance.cgi"
    tpl_time_refresh="5"
    
    rm /tmp/firmware.bin
  fi

  clientservermode=$(uci get bridgebox.general.mode)
  if [ "$clientservermode" = "server" ]; then
    tpl_clientserver_mode=$(translate_inline "Serveur")
  else
    tpl_clientserver_mode="Client"
  fi
  

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
page=$( inject_var "$page" ~tpl_active_acceuil "")
page=$( inject_var "$page" ~tpl_active_code "")
page=$( inject_var "$page" ~tpl_active_wifi "")
page=$( inject_var "$page" ~tpl_active_portail "")
page=$( inject_var "$page" ~tpl_active_avance "active")
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
  
