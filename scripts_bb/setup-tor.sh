#!/bin/sh

if [ ! -d "/tor/omb_hidden_service/" ]; then
    echo "Creating omb hidden service repository"
    mkdir -p /tor/omb_hidden_service/
    chown tor /tor/omb_hidden_service/
    chmod -R 700 /tor/omb_hidden_service/
    chown tor /tor/
fi

if [ ! -f "/var/log/tor.log" ]; then
    echo "Creating log file"
    touch /var/log/tor.log
    chown tor /var/log/tor.log
fi

if [ ! -f "/usr/local/bin/torsocks" ]; then
    echo "symlink torsocks"
    ln -s  /usr/local/bin/torsocks /usr/bin/torsocks
fi

echo "Restarting tor"
/etc/init.d/tor restart
