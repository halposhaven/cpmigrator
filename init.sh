#!/bin/bash

# Includes
source includes.sh

# This script needs to be run as a root user. This is a check to make sure of that.
if [[ $EUID -ne 0 ]]; then
	menu_prep
	export text1="This script must be run as the root user. Please switch to the root user,"
	export text2="and then restart this script."
	submenu
	exit 0
fi

# Two ways to check for the installation of expect, which is required for this scripts to operate.
# (specifically the ssh key copy to the destination server)
expect_workstation=$(dpkg --get-selections 2> /dev/null|awk '/expect/{print $1}'|grep -vw python)
expect_centos=$(rpm -qa 2> /dev/null|awk '/expect/{print $1}'|cut -d '-' -f1|head -1)
# May want to work in an override here, as all scenarios probably won't be accounted for
if [[ -z $expect_workstation ]] && [[ -z $expect_centos ]]; then
	menu_prep
	export text1="This script requires the use of the 'expect' package. Please install before"
	export text2="continuing forward."
        submenu
	exit 0
fi 

menuoptions () {
	menu_prep
	export text1="What Type Of Migration Is This? (Please Choose From The Options Below)"
	export text2="1) Full Migration (All Accounts) Cpanel To Cpanel, With Root SSH Access"
	export text3="2) Partial Migration (List Of Accounts) Cpanel To Cpanel, With Root SSH Access (Not available)"
	export text4="3) Single Account Migration (Shared To Shared, Shared To VPS/Dedicated/Storm) (Not available)"
	export text5="4) Resume A Migration That Was Already Started (Not available)"
	export text6="0) Quit"
	submenu
}

# Prompt the admin with the migration options
if [ -z $STATUS ]; then
        menuoptions
        echo -n "Please Enter Your Choice: "
        read STATUS
fi

case $STATUS in

1) # Starts the full migration scripts
	$path/full-migration/migration-details.sh
	$path/full-migration/server-locations.sh
	$path/full-migration/ssh-keys.sh
	$path/full-migration/starter.sh
	$path/full-migration/wait.sh
	$path/full-migration/final-migration.sh
	echo "Script complete"
;;

2) # Starts partial migration scripts(not yet done)
        $path/partial-migration/partial-migration.sh
;;

3) # Starts single account migration scripts(not yet done)
	$path/single-migration/single-migration.sh
;;
#
4) # Starts the migration-resume scripts(not yet done)
	$path/migration-resume/migration-resume.sh
;;

0) # Exit Gracefully
	echo "Quitting..."
        exit 0;
;;

*) # Default
 echo "Not A Valid Choice. Exiting Program..."
 sleep 2
 clear
esac
