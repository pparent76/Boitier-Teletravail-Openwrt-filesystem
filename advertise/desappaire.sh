#!/bin/sh

echo "Content-type: text/html"
echo ""

# Récuperation des variables
if [ "$REQUEST_METHOD" = "POST" ]; then
read QUERY_STRING
fi
QUERY=`echo $QUERY_STRING | sed -e "s/=/='/g" -e "s/&/';/g" -e "s/+/ /g" -e "s/%0d%0a/<BR>/g" -e "s/$/'/" -e "s/%2C/,/g"`
if [ "$QUERY" != "'" ]&& [ "$QUERY" != "" ]; then
    eval $QUERY
fi

pubkey=$(uhttpd -d "$pubkey")

if [ "${#pubkey}" -ne "44" ]; then
        echo "KO wrong pubkey";
        exit 1;
fi

if [ "$(echo "${pubkey: -1}")" != "=" ]; then
        echo "KO wrong pubkey";
        exit 1;
fi 

if cat /etc/desappaire | grep "$pubkey" >/dev/null 2>&1 ; then
    echo "DESAPPAIRE"
else
    echo "KEEP"
fi
