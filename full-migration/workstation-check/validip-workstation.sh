#!/bin/bash

# Set Path
path=`pwd`

IP=$(cat $path/full-migration/config/files/workstation-IP)

validip () {
        valid=1
        count=0

        for field in $(echo "$IP" | cut -d. --output-delimiter=$'\012' -f1-); do
                count=$[count+1]
        if [ "$field" -eq $[field+0] -a "$field" -le 256 -a "$field" -ge 0 ]; then
                : yay
        else
                valid=0
        fi
        done

        if [ "$valid" -a "$count" -eq 4 ]; then
		echo ""
                echo "Valid IP address!"
		echo ""
        else
                echo "Invalid IP address!"
		echo
		echo "Quitting program..."
		sleep 1
		exit 0;
        #SUBLOOP=0
        fi
}

validip

# Script Ends. Returns to server-locations.sh
