#!/bin/bash
# Initiated from migration-details.sh

# Set Path
path=`pwd`

sourceIP=$(cat $path/full-migration/destinationIPtest)

validip () {
        valid=1
        count=0

        for field in $(echo "$sourceIP" | cut -d. --output-delimiter=$'\012' -f1-); do
                count=$[count+1]
        if [ "$field" -eq $[field+0] -a "$field" -le 256 -a "$field" -ge 0 ]; then
                : yay
        else
                valid=0
        fi
        done

        if [ "$valid" -a "$count" -eq 4 ]; then
		echo "1" >> $path/full-migration/preliminary/validip-dest
	else
		echo "0" >> $path/full-migration/preliminary/validip-dest
        fi
}

validip

# Script Ends. Returns to migration-details.sh
