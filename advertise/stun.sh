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

sourceport=$(cat /tmp/bb/server/stun-local-port)

##################################################
#we need to check challenge for security reasons
##################################################
challengesrc=$(cat  /advertise/challenge)
challengeok=0;
challenge=$(uhttpd -d "$challenge")
while IFS='' read -r line || [[ -n "$line" ]]; do
 if [ "$line" != "" ]; then 
    code=$(echo "$line" | tr '#' '\n' | head -n 4 | tail -n 1 | tr '\n' ' ' | sed "s/ //g") 
    clefl=$(echo "$line" | tr '#' '\n' | head -n 2 | tail -n 1 | tr '\n' ' ' | sed "s/ //g")  
    ipl=$(echo "$line" | tr '#' '\n' | head -n 3 | tail -n 1 | tr '\n' ' ' | sed "s/ //g")         
    challengeres=$(echo "$challenge" | openssl aes-256-cbc -d  -a -pass pass:$code)
    if [ "$challengeres" = "$challengesrc" ]; then
        # RESET PEER
        sudo /usr/bin/wg rm peer allowed-ips $ipl/32 
        sudo /usr/bin/wg set wg0 peer $clefl allowed-ips $ipl/32 
        challengeok=1;
    fi
  fi
done < /etc/server-codes


if [ "$sourceport" != "" ]&& [ "$challengeok" -eq "1" ]; then

    #we create a new challenge for next request
    date +%s | sha256sum | head -c 42 > /advertise/challenge
	sudo /usr/sbin/conntrack -D -d $ip  >/tmp/resconntrack 2>&1 
	sudo /usr/sbin/conntrack -D -s $ip  >/tmp/resconntrack 2>&1 	
	
    sudo /usr/bin/dummyudp $sourceport $ip $port
#     date >> /tmp/advertise-stun
#     echo  "$sourceport $ip $port" >> /tmp/advertise-stun
    if [ "$?" -eq "0" ]; then
	sudo /usr/sbin/conntrack -D -d $ip -p udp --dport $port --sport $sourceport >/tmp/resconntrack 2>&1 
	sudo /usr/sbin/conntrack -D -s $ip -p udp --sport $port --dport $sourceport >/tmp/resconntrack 2>&1 	
        echo "OK"
    fi
else
    echo "KO"
    if [ "$challengesrc" = "" ]; then
       date +%s | sha256sum | head -c 42 > /advertise/challenge
    fi
fi
