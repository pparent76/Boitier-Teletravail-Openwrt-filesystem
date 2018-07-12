#!/bin/sh

ip="2.2.2.2"
clientserver=$(sudo /sbin/uci get bridgebox.general.mode)
langue=$(sudo /sbin/uci get bridgebox.general.langue)

if [ "$clientserver" = "" ]||  [ "$langue" = "" ]; then
    page="cgi/Init-lang-mode.cgi"
else
    page="cgi/home.cgi"
fi
echo "<html><header><meta http-equiv=\"refresh\" content=\"0;url=http://$ip/$page \" /></header></html>"   
