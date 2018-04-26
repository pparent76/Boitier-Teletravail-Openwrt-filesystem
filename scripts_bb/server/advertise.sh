#!/bin/sh

is_port_configured=$(cat /tmp/bb/server/port-configured)
ip=$(cat /tmp/bb/server/ip)
port=$(cat /tmp/bb/server/port)
port_type=$(cat /tmp/bb/server/port-type)

if [ "$is_port_configured" = "1" ]; then
    echo "BEGINADVERTISE $port_type $ip $port ENDADVERTISE" > /advertise/index.html
else
    echo "BEGINADVERTISE none ENDADVERTISE" > /advertise/index.html
fi
