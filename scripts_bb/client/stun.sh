#!/bin/sh

logfile_stun=/var/log/stun
  
log_stun() {
  thedate=$(date);
  echo "[$thedate]- $*" >> $logfile_stun
  if [ -f "/tmp/verbose" ]; then
    printf "[stun]$*\n"
  fi
}

log_stun "start stun script"

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for  i in $( seq 0 $length ); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

urlencode_many_printf () {
  string=$1
  while [ -n "$string" ]; do
    tail=${string#?}
    head=${string%$tail}
    case $head in
      [-._~0-9A-Za-z]) printf %c "$head";;
      *) printf %%%02x "'$head"
    esac
    string=$tail
  done
  echo
}

########################################################
#           try to reach a stun server
########################################################

stunok=0;

rm /tmp/stunres

code=$(uci get bridgebox.client.stuncode )

for i in $( seq 1 3 ); do

    stunserver=$(uci get bridgebox.advanced.stun$i)
    stunport=$(uci get bridgebox.advanced.stunport$i)
    
    if [ "$stunserver" != "" ] && [ "$stunport" != "" ]; then
        stunclient $stunserver $stunport > /tmp/stunres
    fi
    cat /tmp/stunres | grep "success"

    
    if [ "$?" -eq "0" ]; then
        stun_localport=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )
        stun_mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )  
        stun_publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )  
        stun_localip=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )      
        echo "Stun Port Ok $stunserver  $stunport"
        stunok=1;
        break
    else
        echo "stun $stunserver $port unreachable"
    fi
done

if [ "$stunok" -ne "1" ]; then
    return 1;
fi


log_stun "stun mapped local  $stun_mappedport $stun_localport"

if [ "$stun_publicip" = "$ip" ]; then
    log_stun "We are behind the same nat that the other bridgebox, using local adresses"
    #stun_publicip=192.168.1.1;
    stun_publicip="$stun_localip";
    stun_mappedport=$stun_localport;
    export ip="$localip";
fi

log_stun "remote $ip $port"


rm /tmp/dummyudp-server


serverid=$(uci get bridgebox.client.server_id )
for i in $(seq 1 3); do
   ##################################################################################################
   #                                Try with hiddenservice
   ##################################################################################################
   killall dummyudp-server; dummyudp $stun_localport $ip $port; dummyudp-server $stun_localport >> /tmp/dummyudp-server 2>&1 & 
   
   log "dummyudp-server $stun_localport"
    torproxy=$(uci get bridgebox.advanced.torproxy)
    
       
    #Get challenge
    wget-tor-proxy $serverid challenge | tail -n 1 > /tmp/stun-challenge
    challengesrc=$(cat /tmp/stun-challenge)
    challengeres=$(echo "$challengesrc" | openssl enc -aes-256-cbc -a -pass pass:$code)
    challengeres=$(urlencode_many_printf "$challengeres")
    
    url=$(printf "stun.sh?ip=$stun_publicip";urlencode_many_printf "&port=$stun_mappedport&challenge=$challengeres")
    #Ask for server push-hole
    log_stun " wget-tor-proxy $serverid $url"
    wget-tor-proxy $serverid $url > /tmp/stun-try-res


    
    #Wait and see if we could get a dummy reply from server
    sleep 1;
    cat /tmp/dummyudp-server | grep dummy
    if  [ "$?" -eq "0" ]; then
        log_stun "Could establish stun pushhole with  $serverid (me ip=$stun_publicip\&port=$stun_mappedport) with $torproxy" 
        log_stun "(challenge= $challengesrc)"
        killall dummyudp-server
        return 0;
    fi
    
    

   ##################################################################################################
   #                                Try with torsocks
   ##################################################################################################
    #Send a dummmy udp package to server and record dummy reply
    killall dummyudp-server; dummyudp $stun_localport $ip $port; dummyudp-server $stun_localport >> /tmp/dummyudp-server 2>&1 &
   

    #wget
     torsocks wget --retry-connrefused --waitretry=1 -t 2 $serverid.onion/challenge --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/stun-challenge > /dev/null 2>&1
    challengesrc=$(cat /tmp/stun-challenge)
    challengeres=$(echo "$challengesrc" | openssl enc -aes-256-cbc -a -pass pass:$code)
    challengeres=$(urlencode_many_printf "$challengeres")
    log_stun "http://$serverid.onion/stun.sh?ip=$stun_publicip\&port=$stun_mappedport\&challenge=$challengeres"
    torsocks wget --retry-connrefused --waitretry=1 -t 2 $serverid.onion/stun.sh?ip=$stun_publicip\&port=$stun_mappedport\&challenge=$challengeres --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-stun-res > /dev/null 2&>1
    
    #Wait and see if we could get a dummy reply from server
    sleep 1;
    cat /tmp/dummyudp-server | grep dummy
    if  [ "$?" -eq "0" ]; then
        log_stun "Could establish stun pushhole with  $serverid (me ip=$stun_publicip\&port=$stun_mappedport) with torsocks"
        log_stun "(challenge= $challengesrc)"
        killall dummyudp-server
        return 0;
    fi


    log_stun "New attempt to push udp hole"
done 

killall dummyudp-server
log_stun "Failed to push UDP hole"
return 1;
