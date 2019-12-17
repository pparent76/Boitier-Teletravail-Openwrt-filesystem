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


##################################################
#we need to check challenge for security reasons
##################################################
code="f0129173a9bf4a889cdd62c30e7c86395b0931f91e";
challengesrc=$(cat  /appaire/challenge)
challengeok=0;
challenge=$(uhttpd -d "$challenge")  
challengeres=$(echo "$challenge" | openssl aes-256-cbc -d -base64  -a -pass pass:$code)
mac=$(uhttpd -d "$mac")
pubkey=$(uhttpd -d "$pubkey")

if [ "$challengeres" = "$challengesrc" ]; then
        challengeok=1;
fi

# TODO check mac is a mac and pubkey is a pubkey
if [ "$challengeok" -eq "1" ]; then
    
    #we create a new challenge for next request
    date +%s | sha256sum | head -c 42 > /appaire/challenge
    
    mypubkey=$(sudo /usr/bin/get-pubkey)
    myid=$(sudo  /usr/bin/get-id)
    
    #call script
    ip=$(sudo /scripts_bb/server/appaire-script.sh "$mac" "$pubkey";)
    if [ "$?" -eq "0" ]; then
        echo "OK $myid $mypubkey $ip"
    else
        echo "KO"
    fi
else
    echo "KO"
    if [ "$challengesrc" = "" ]; then
       date +%s | sha256sum | head -c 42 > /appaire/challenge
    fi
fi
