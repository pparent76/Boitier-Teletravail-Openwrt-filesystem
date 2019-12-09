#!/bin/sh

cd /root/

 wg genkey > privatekey
 wg pubkey < privatekey > publickey
