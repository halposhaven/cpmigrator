#!/bin/bash
# Initiated from init.sh

# Includes
source includes.sh
clear

# Set location
location=$(cat $path/full-migration/location)

# Inform admin of current status
menu_prep
export text1="Starting Initial Migration Process from $location ..."
submenu

# Based on location set by server-locations.sh,
# run appropriate initial migration script

if [[ $location == source ]]; then
	bash $path/full-migration/source-initial-migration.sh
fi

if [[ $location == destination ]]; then
	bash $path/full-migration/
fi

if [[ $location == thirdparty ]]; then
	bash $path/full-migration/
fi

# Script end. Returns to init.sh
