#!/bin/sh

clientservermode=$(uci get bridgebox.general.mode)

if [ "$clientservermode" = "client" ]; then
    /site/cgi/code-client.cgi
else
    /site/cgi/code-server.cgi
fi
