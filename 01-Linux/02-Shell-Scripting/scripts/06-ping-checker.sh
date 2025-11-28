#!/bin/bash
read -p "Enter domain: " domain
ping -c 1 $domain &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "Online"
else
    echo "Offline"
fi
