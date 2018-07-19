#!/bin/sh

ip="2.2.2.2"
clientserver=$(sudo /sbin/uci get bridgebox.general.mode)
langue=$(sudo /sbin/uci get bridgebox.general.langue)
ipwan=$(ifconfig br-wan | grep inet | awk '{print $2}' | cut  -d: -f2 | head -n1)

echo "$SERVER_NAME" | grep "\." >/dev/null 2>&1
if [ "$?" -ne "0" ]; then
    ip="$SERVER_NAME";
fi

if [ "$ipwan" = "$SERVER_NAME" ]; then
    ip="$SERVER_NAME";
fi


if [ "$clientserver" = "" ]||  [ "$langue" = "" ]; then
    page="cgi/Init-lang-mode.cgi"
else
    page="cgi/home.cgi"
fi
echo "<html><header><meta http-equiv=\"refresh\" content=\"0;url=http://$ip/$page \" /></header></html>"   
