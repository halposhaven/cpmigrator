#!/bin/bash
# This script is initiated from init.sh
# This is the 3rd script to run for a full migration, after migration-details.sh and server-locations.sh

# Includes
source includes.sh

# Set location
location=$(cat $path/full-migration/location)

# Based on location set by server-locations.sh, 
# runs appropriate script(s) to setup ssh keys

# If current location is source server 
if [[ $location == source ]]; then
	bash $path/full-migration/ssh-dest.sh
	menu_prep
	export text1="SSH Key With Destination Server Has Been Setup"
	submenu
fi

# If current location is destination server
if [[ $location == destination ]]; then
	bash $path/full-migration/ssh-src.sh
	menu_prep
	export text1="SSH Key With Source Server Has Been Setup"
	submenu
fi

# If current location is thirdparty server
if [[ $location == thirdparty ]]; then
	bash $path/full-migration/ssh-src.sh
	bash $path/full-migration/ssh-dest.sh
	menu_prep
	export text1="SSH Keys With Source and Destination Servers Have Been Setup"
	submenu
fi

# If current location is workstation
if [[ $location == workstation ]]; then
	bash $path/full-migration/ssh-src.sh
	bash $path/full-migration/ssh-dest.sh
        menu_prep
        export text1="SSH Keys With Source and Destination Servers Have Been Setup"
        submenu
fi

# If current location is unkown
if [[ $location != source ]] && [[ $location != destination ]] && [[ $location != workstation ]]; then
	menu_prep
	export text1="Unkown location: $location . Exiting script..."
	submenu
	exit 0
fi

# Script End. Returns to init.sh
