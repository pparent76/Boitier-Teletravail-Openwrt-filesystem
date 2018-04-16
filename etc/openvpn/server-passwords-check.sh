#!/bin/sh

read  username < $1
read  password < $1

# Replace your own authentication mechanism here
if [[ "$password" == "Pierre" ]]; then
  echo "ok"
  exit 0
fi

echo "not ok"
exit 1 
