#!/bin/bash
# This script is initiated from init.sh
# It is the first script run from there as part of a full migration

# Includes
source includes.sh

# Clear flat files written to in this script
for each in `\ls -A1 $path/full-migration/source-files|grep source`; do cat /dev/null > $path/full-migration/source-files/$each;done
for each in `\ls -A1 $path/full-migration/destination-files|grep destination`; do cat /dev/null > $path/full-migration/destination-files/$each;done
cat /dev/null > $path/full-migration/sourceIPtest
cat /dev/null > $path/full-migration/destinationIPtest

# Inform tech to fill out migration information for source server
	menu_prep
	export text1="Please Fill Out The Following Migration Details"
	export text2="1) Source Server IP Address"
	export text3="2) Source Server SSH Port"             
	export text4="3) Source Server Root Password"
	submenu

# Gather migration information for source server
sourceserverinfo () {
        SUBLOOP=0
        while [ $SUBLOOP -eq 0 ];
        do
		# Grabs source IP
                if [ -z $sourceIP ]; then
                	echo -n "Source Server IP Address: "
                	read sourceIP
                fi
                SUBLOOP=1
                # IP is required
		# This needs more work. If the IP address is invalid, it needs to prompt for a new one
		# instead of just continuing on
		# * Needs to go into its own while loop
                if [ -z $sourceIP ]; then
			echo ""
                        echo "IP Address Is Required! Please Enter A Valid IP Address."
			echo ""
                        sleep 1
                        SUBLOOP=0
                else
			echo $sourceIP >> $path/full-migration/sourceIPtest
                        $path/full-migration/validip-src.sh
                fi
                # Set user to root
			sourceUSER=root
                #Get SSH Port
                if [ -z $sourcePORT ]; then
                        echo -n "Source Server SSH Port [22]: "
                        read sourcePORT
			SUBLOOP=1
                fi
                # Assign port 22 if no value was assigned
                if [ -z $sourcePORT ]; then
			echo ""
                        echo "No Port Given, Assuming Port 22."
                        sleep 1
                        sourcePORT=22
			#SUBLOOP=1
                fi
                # Get Source Server password
                if [ -z $sourcePASS ]; then
			echo ""
                        echo -n "Source Server Password: "
                        read sourcePASS
                        SUBLOOP=1
                fi
                # Password is required
                if [ -z $sourcePASS ]; then
			echo ""
                        echo "Source Password Required!"
			echo ""
                        SUBLOOP=0
                fi
        done
}

# Run script for source server
sourceserverinfo

# Copy source server variables to flat files
echo $sourceIP >> $path/full-migration/source-files/sourceIP
echo $sourceUSER >> $path/full-migration/source-files/sourceUSER
echo $sourcePORT >> $path/full-migration/source-files/sourcePORT
echo $sourcePASS >> $path/full-migration/source-files/sourcePASS

# Inform User Of Information Save
echo 
echo "Source Server Information Saved!"
echo 
sleep 2

# Inform tech to fill out migration information for destination server
	menu_prep
	export text1="Please Fill Out The Following Migration Details"
	export text2="1) Destination Server IP Address"
	export text3="2) Destination Server SSH Port"
	export text4="3) Destination Server Root Password"
	submenu

# Migration information for destination server 
destinationserverinfo () {
        SUBLOOP=0
        while [ $SUBLOOP -eq 0 ];
        do
		# Get destination server IP
                if [ -z $destinationIP ]; then
                	echo -n "Destination Server IP Address: "
                	read destinationIP
                fi
                SUBLOOP=1
                # IP is required
                if [ -z $destinationIP ]; then
                        echo ""
                        echo "IP Address Is Required! Please Enter A Valid IP Address."
                        echo ""
                        sleep 1
                        SUBLOOP=0
                        destinationserverinfo
                else
                        echo $destinationIP >> $path/full-migration/destinationIPtest
                        $path/full-migration/validip-dest.sh
                fi
                # Set user to root
                        destinationUSER=root
                #Get SSH Port
                if [ -z $destinationPORT ]; then
                        echo -n "Destination Server SSH Port [22]: "
                        read destinationPORT
			SUBLOOP=1
			
                fi
                # Assign port 22 if no value was assigned
                if [ -z $destinationPORT ]; then
                        echo ""
                        echo "No Port Given, Assuming Port 22."
                        sleep 1
                        destinationPORT=22
			#SUBLOOP=1
                fi
                # Get Destination Server password
                if [ -z $destinationPASS ]; then
			echo ""
                        echo -n "Source Server Password: "
                        read destinationPASS
                        SUBLOOP=1
                fi
                #Password is required
                if [ -z $destinationPASS ]; then
                        echo ""
                        echo "Destination Password Required!"
                        echo ""
                        SUBLOOP=0
                fi
        done
}

destinationserverinfo

# Copy source server variables to flat files
echo $destinationIP >> $path/full-migration/destination-files/destinationIP
echo $destinationUSER >> $path/full-migration/destination-files/destinationUSER
echo $destinationPORT >> $path/full-migration/destination-files/destinationPORT
echo $destinationPASS >> $path/full-migration/destination-files/destinationPASS

# Inform User Of Information Save
echo 
echo "Destination Server Information Saved!"
echo 
sleep 2

# Script End. Returns to init.sh
