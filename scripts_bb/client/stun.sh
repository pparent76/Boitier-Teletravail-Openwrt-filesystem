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
stunclient stun.12voip.com 3478 > /tmp/stunres

cat /tmp/stunres | grep "success"

if [ "$?" -eq "0" ]; then
    stun_localport=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )
    stun_mappedport=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $2}'  )  
    stun_publicip=$(cat /tmp/stunres | grep Mapped | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )  
    stun_localip=$(cat /tmp/stunres | grep Local | awk '{print $3}' | sed "s/:/ /g" | awk '{print $1}'  )      
    log_stun "Stun Port Ok"
else
    log_stun "stun unreachable"
    return 1;
fi

if [ "$stun_publicip" = "$ip" ]; then
    log_stun "We are behind the same nat that the other bridgebox, using local adresses"
    #stun_publicip=192.168.1.1;
    stun_publicip="$stun_localip";
    export ip="$localip";
fi

rm /tmp/dummyudp-server


serverid=$(uci get bridgebox.client.server_id )
for i in $(seq 1 3); do

   ##################################################################################################
   #                                Try with torsocks
   ##################################################################################################
    #Send a dummmy udp package to server and record dummy reply
    killall dummyudp-server; dummyudp $stun_localport $ip $port; dummyudp-server $stun_localport >> /tmp/dummyudp-server 2>&1 &
   
    log_stun "$serverid.onion/stun.sh?ip=$stun_publicip\&port=$stun_mappedport"
    #wget
    torsocks wget $serverid.onion/stun.sh?ip=$stun_publicip\&port=$stun_mappedport --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-res > /dev/null 2&>1
    
    #Wait and see if we could get a dummy reply from server
    sleep 1;
    cat /tmp/dummyudp-server | grep dummy
    if  [ "$?" -eq "0" ]; then
        log_stun "Could establish stun pushhole with  $serverid (me ip=$stun_publicip\&port=$stun_mappedport) with torsocks"
        killall dummyudp-server
        return 0;
    fi

   ##################################################################################################
   #                                Try with hiddenservice
   ##################################################################################################
   killall dummyudp-server; dummyudp $stun_localport $ip $port; dummyudp-server $stun_localport >> /tmp/dummyudp-server 2>&1 & 
   
   #Ask for server push-hole
    wget $serverid.hiddenservice.net/stun.sh?ip=$stun_publicip\&port=$stun_mappedport --timeout=30 --dns-timeout=30 --connect-timeout=30 --read-timeout=30 -O /tmp/advertised-res > /dev/null 2&>1
    
    #Wait and see if we could get a dummy reply from server
    sleep 1;
    cat /tmp/dummyudp-server | grep dummy
    if  [ "$?" -eq "0" ]; then
        log_stun "Could establish stun pushhole with  $serverid (me ip=$stun_publicip\&port=$stun_mappedport) with hiddenservice.net" 
        killall dummyudp-server
        return 0;
    fi
    
    log_stun "New attempt to push udp hole"
done 

killall dummyudp-server
log_stun "Failed to push UDP hole"
return 1;
