#!/bin/bash
# Initiated from init.sh

clear
path=`pwd`
location=$(cat $path/full-migration/location)

# Menu functions
menu_prep () {
        for each in text{1..6};do unset $each;done
        clear
}
submenu () {
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
}

# Inform admin of current status
export text1="Starting Initial Migration Process from $location ..."

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
