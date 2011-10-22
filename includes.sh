#!/bin/bash

# Unalias ls
unalias ls 2> /dev/null

# Set path to current location
path=`pwd`

# Functions for submenu
menu_prep () {
        for each in text{1..6};do unset $each;done
        clear
}

submenu () {
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
}

# Function for location clear
location_clear () {
        cat /dev/null > $path/full-migration/location
}
