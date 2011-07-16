#!/bin/bash
# This script is initiated from init.sh
# This is the 3rd script to run for a full migration, after migration-details.sh and server-locations.sh
clear
# Set path and read location
path=`pwd`
location=$(cat $path/full-migration/location)

# Based on location set by server-locations.sh, 
# runs appropriate script(s) to setup ssh keys

# If current location is source server 
if [[ $location == source ]]; then
	bash $path/full-migration/ssh-dest.sh
	clear
	echo
	echo "SSH Key With Destination Server Has Been Setup"
	echo
fi

# If current location is destination server
if [[ $location == destination ]]; then
	bash $path/full-migration/ssh-src.sh
	clear
	echo
	echo "SSH Key With Source Server Has Been Setup"
	echo
fi

# If current location is thirdparty server
if [[ $location == thirdparty ]]; then
	bash $path/full-migration/ssh-src.sh
	bash $path/full-migration/ssh-dest.sh
	clear
	echo
	echo "SSH Keys With Source and Destination Servers Have Been Setup"
	echo
fi

# If current location is workstation
if [[ $location == workstation ]]; then
	bash $path/full-migration/ssh-src.sh
	bash $path/full-migration/ssh-dest.sh
        clear
        echo
        echo "SSH Keys With Source and Destination Servers Have Been Setup"
        echo
fi

# If current location is unkown
if [[ $location != source ]] && [[ $location != destination ]] && [[ $location != workstation ]]; then
	echo
	echo "Unkown location: $location . Exiting script..."
	exit 0
fi

sleep 3
# Script End. Returns to init.sh
