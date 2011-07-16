#!/bin/bash
# Initiated from init.sh

clear
path=`pwd`
location=$(cat $path/full-migration/location)

# Inform admin of current status
echo "Starting Initial Migration Process from $location ..."
sleep 2

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
