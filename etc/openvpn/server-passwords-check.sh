#!/bin/sh

read  username < $1
read  password < $1

while IFS='' read -r line || [[ -n "$line" ]]; do
 if [ "$line" != "" ]; then 
    code=$(echo "$line" | tr '#' '\n' | head -n 1 | tr '\n' ' ' | sed "s/ //g")  
    # Replace your own authentication mechanism here
    if [[ "$password" == "$code" ]]; then
        echo "ok"
        exit 0
    fi 
  fi
done < /etc/server-codes



echo "not ok"
exit 1 
