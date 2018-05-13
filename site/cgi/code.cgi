#!/bin/sh

clientservermode=$(uci get bridgebox.general.mode)

if [ "$clientservermode" = "client" ]; then
    /site/cgi/code-client.cgi
fi
