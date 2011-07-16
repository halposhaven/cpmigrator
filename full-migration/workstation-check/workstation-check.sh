#!/bin/bash

# Set Variables
path=`pwd`
check=$(ifconfig | grep "inet addr:" | grep -vw "127.0.0.1" | cut -d ':' -f2 | cut -d ' ' -f1)

# Clear Flat File
cat /dev/null > $path/full-migration/config-files/workstation-IP

# 
echo
echo "Is the public IP of your workstation $check ?"
echo

if [ -z $correctIP ]; then
	echo -n "Please type yes or no: "
        read correctIP
fi
if [[ $correctIP == yes ]]; then
	echo $check > $path/full-migration/config-files/workstation-IP
	echo
	echo "Saving IP..."
	sleep 1 
fi

if [[ $correctIP == no ]]; then
	if [ -z $workstationIP ]; then
		echo
		echo -n "Please enter your workstation's public IP address: "
		read workstationIP
		echo
		echo $workstationIP > $path/full-migration/config-files/workstation-IP
		#bash $path/full-migration/config-files/workstation-IP-test
		echo "Saving IP..."
		sleep 1
	fi
fi

if [[ $correctIP != no ]] && [[ $correctIP != yes ]]; then
	echo
	echo "That is not a valid answer!"
	echo
	echo "Quitting program..."
	sleep 1
	exit 0;
fi

# Script end. Returns to server-locations.sh 
