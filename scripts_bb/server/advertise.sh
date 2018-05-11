#!/bin/sh

is_port_configured=$(cat /tmp/bb/server/port-configured)
ip=$(cat /tmp/bb/server/ip)
port=$(cat /tmp/bb/server/port)
port_type=$(cat /tmp/bb/server/port-type)
localip=$( ifconfig br-wan  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' )

if [ "$is_port_configured" = "1" ]; then
    echo "BEGINADVERTISE $port_type $ip $port $localip ENDADVERTISE" > /advertise/index.html
else
    echo "BEGINADVERTISE none ENDADVERTISE" > /advertise/index.html
fi
