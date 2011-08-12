#!/bin/bash
# Initiated from starter.sh

path=`pwd`
menu_prep () {
        for each in text{1..6};do unset $each;done
        clear
}

# Set destination server variables
destinationIP=$(cat $path/full-migration/destination-files/destinationIP)
destinationPASS=$(cat $path/full-migration/destination-files/destinationPASS)
destinationPORT=$(cat $path/full-migration/destination-files/destinationPORT)
destinationUSER=$(cat $path/full-migration/destination-files/destinationUSER)

# Provide some basic information about the current status of the server
system_info () {
	menu_prep
	export text1="################## Initial Migration To Destination Server ###################"
	export text2="Begin System Information ..."
	export text3="The following information will also be logged to:"
	export text4="$path/full-migration/system_info_start"
	$path/full-migration/menu_templates/submenu.sh
        sleep 2
	echo "You are connected as the user: $USER " 
	echo
	echo "Today's date is `date`, this is week `date +"%V"`."
	echo
	echo "The following users are currently connected:"
	w|cut -d " " -f1|grep -v USER|sort -u
	echo
	echo "This is `uname -s` running on a `uname -m` processor,"
	echo "and running this kernel: `uname -r`"
	echo
	echo "CentOS version is:"
	cat /etc/redhat-release
	echo
	echo "This is the current uptime information:"
	uptime
	echo
	echo "If you see anything amiss here, please feel free to exit this script now.
	      It can be easily resumed from the main menu."
	echo
	read -p "Press any key to continue..."
}

preliminary () {
# Also nameservers. Should have as query at beginning of migration

	# Clear flat files used in this section
	cat /dev/null > $path/full-migration/preliminary/users 2>&1 >/dev/tty
	[ -f $path/full-migration/preliminary/user_conflicts ] && rm -f $path/full-migration/preliminary/user_conflicts
	[ -f $path/full-migration/preliminary/domain_conflicts ] && rm -f $path/full-migration/preliminary/domain_conflicts
	for each in `\ls -A1 $path/full-migration/preliminary`; do cat /dev/null > $path/full-migration/preliminary/$each 2>&1 >/dev/tty;done
        
	menu_prep
	export text1="################## Initial Migration To Destination Server ###################"
	export text2="Begin Preliminary Migration Checks For ..."
	export text3="-Cpanel User Accounts On the Destination Server"
	export text4="-Available IPs. Are There Enough On the Destination Server To Match Setups?"
	export text5="-Nameservers. Have They Been Setup? If Not, They Will Be Created."
	$path/full-migration/menu_templates/submenu.sh
        sleep 2
	echo "Running Checks ..."
	sleep 2
	# Check for existing users on remote server
	ssh $destinationUSER@$destinationIP -p $destinationPORT "\ls -A1 /var/cpanel/users" > $path/full-migration/preliminary/users
	dest_users=$(cat $path/full-migration/preliminary/users)
	if [[ -f $path/full-migration/preliminary/users ]]; then
		echo "Users found on target server"
		sleep 2
		# Check for account and domain conflicts
		ssh $destinationUSER@$destinationIP -p $destinationPORT "cat /etc/userdatadomains | cut -d ':' -f1" > $path/full-migration/preliminary/domains
		for each in `cat $path/full-migration/preliminary/users`;do `\ls -A1 /var/cpanel/users|grep -x $each|uniq -ui >> $path/full-migration/preliminary/user_conflicts`;done
		for each in `cat $path/full-migration/preliminary/domains`;do `cat /etc/userdatadomains|cut -d ':' -f1|grep -x $each|uniq -ui >> $path/full-migration/preliminary/domain_conflicts`;done
		# If there are conflicts, inform the admin
		if [[ -f $path/full-migration/preliminary/user_conflicts ]]; then
			        menu_prep
        			export text1="################## Initial Migration To Destination Server ###################"
        			export text2="ATTENTION: The following accounts already exist on the target server."
        			$path/full-migration/menu_templates/submenu.sh
				sleep 2
				echo "Account Name Conflicts:"
				echo
				cat $path/full-migration/preliminary/user_conflicts
				echo
				echo "By default, these domains will be excluded from the initial migration."
				echo "If you would to continue, press any key. If you would like to instead"
				echo "override this, type 'no'."
				# Allow admin to override.
        		        if [ -z $conflict_continue ]; then
					echo
                        		echo -n "Press any key to continue, or type 'no':"
                        		read conflict_continue
                			if [ -z $conflict_continue ]; then
                        			echo 
                        			echo "Listed accounts will be excluded from initial migration."
                        			sleep 2
					fi
					if [ $conflict_continue == no ];then
						cat "override" > $path/full-migration/preliminary/conflict_override
						echo
						echo "Override completed. Script will attempt to move all accounts"
						echo "on the server regardless of found conflicts."
					fi
                		fi
	
		fi
		# May cut this one out, or find a way to pair with conflict accts, or only display if NOT paired with any conflicted accounts
		if [[ -f $path/full-migration/preliminary/domain_conflicts ]]; then
				menu_prep
                                export text1="################## Initial Migration To Destination Server ###################"
                                export text2="ATTENTION: The following domains already exist on the target server."
                                $path/full-migration/menu_templates/submenu.sh
				sleep 2
				echo "Domain and Subdomain Conflicts:"
				echo
				cat $path/full-migration/preliminary/domain_conflicts
				echo
				read -p "Press any key to continue..."
		fi
	else
		# No conflicts, but accounts do exist on target server. Inform admin.
		menu_prep
                export text1="################## Initial Migration To Destination Server ###################"
                export text2="ATTENTION: The target server is in use, and the following accounts are setup."
                $path/full-migration/menu_templates/submenu.sh
                sleep 2
		echo "Accounts on Target Server:"
		echo
		cat $path/full-migration/preliminary/users
		echo
		read -p "Press any key to continue ..."
		# Give choice to match configs or not. Write choice to file. Make EA matcher check this file before starting
	fi
	
	# Dedicated IPs
	cat /etc/userdatadomains|sed -e 's/:/ /g' -e 's/==/ /g'|cut -d ' ' -f8|tr -d [:blank:]|sort|uniq >> $path/full-migration/preliminary/ips
	mainip=$(cat /etc/wwwacct.conf|grep ADDR|cut -d ' ' -f2)
	for each in `cat $path/full-migration/preliminary/ips`; do 
		if [[ $each != $mainip ]]; then
			echo $each  >> $path/full-migration/preliminary/dedipaccts
		fi
	done
	# Number of dedicated IPs needed
	cat $path/full-migration/preliminary/dedipaccts|wc -l >> $path/full-migration/preliminary/ips_needed
	# Check target server for number of IPs
	ssh -t $destinationUSER@$destinationIP -p $destinationPORT "cat /etc/ips|wc -l" >> $path/full-migration/preliminary/target_partial
	# Compare source and target server IP numbers
	target_partial=$(cat $path/full-migration/preliminary/target_partial)
	target_ips=$(($target_partial + 1))
	echo $target_ips >> $path/full-migration/preliminary/target_ips
	ips_needed=$(cat $path/full-migration/preliminary/ips_needed)
	# If there are not enough, inform the admin, along with how many IPs are needed
	if [[ $target_ips -lt $ips_needed ]]; then
		add_ips=$(($ips_needed - $target_ips))
		menu_prep
                export text1="################## Initial Migration To Destination Server ###################"
                export text2="ATTENTION: The target server does not have enough IPs for accounts with" 
		export text3="           dedicated IPs."
                $path/full-migration/menu_templates/submenu.sh
		sleep 2
		echo "$add_ips IP(s) need to be added to the target server in order to match configurations"
		echo
		echo "Please go ahead and add IPs to the target server. If you would like to instead"
		echo "override this, and restore all accounts to the main shared IP, just type "no"."
	        if [ -z $continue ]; then
                echo -n "Please type yes or no: "
                read continue
        	fi
		# Continue if correct amount of IPs have now been added to destination server.
		if [[ $continue == yes ]]; then
			echo
			echo "Continuing migration, and assuming there are now enough IPs on the target server ..."
			echo
			sleep 2
		fi
		# If admin wants to go ahead anyways. Restores all accounts to main shared IP
		if [[ $continue == no ]]; then
			echo
			echo "Continuing migration, and will restore all accounts to main shared IP."
			echo
			echo "Yes" >> $path/full-migration/preliminary/restore_to_shared
		fi
	else
		menu_prep
                export text1="################## Initial Migration To Destination Server ###################"
                export text2="The target server has enough IPs to keep the current IP configuration."
                $path/full-migration/menu_templates/submenu.sh
                sleep 2
	fi
	# This also needs to take nameservers into account	
}

# Lowers TTLs. Snagged from migration wiki
ttls () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Now Lowering TTLs ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	#check current TTLs and serial number
	grep --color -e '^\$TTL.*' -e '[0-9]\{10\}' /var/named/*.db   # this [0-9]\{10\}  will be the serial number, 10 numbers in a row
 	#make sure date works
	date +%Y%m%d%H
 	#the -i flag will create backups in the same directory, liquidweb.com.lwbak for example
	sed -i.lwbak -e 's/^\$TTL.*/$TTL 300/g' -e 's/[0-9]\{10\}/'`date +%Y%m%d%H`'/g' /var/named/*.db
 	#check your work
	grep --color -e '^\$TTL.*' -e '[0-9]\{10\}' /var/named/*.db
	# Handles individually set TTLs for records, which are most commonly at 14400
	grep 14400 /var/named/*.db -Rl|xargs sed -i 's/14400/300/g'
	rndc reload
	echo
	echo "TTLs Lowered"
}

# Checks for remote nameservers. Snagged from migration wiki
nameservers () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Checking For Remote Nameservers ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	[ -f $path/remote_dns ] && cat /dev/null > $path/remote_dns
	counter=1
	for ns in `cat /etc/nameserverips|cut -d '=' -f2`;do
       		nsarray[$counter]=`echo $ns|tr "[:upper:]" "[:lower:]"`
       		counter=`expr $counter + 1`
	done

	for domain in `cat /etc/userdomains|grep -v \*|cut -d ':' -f1|egrep "^[a-zA-Z0-9]([-]?[a-zA-Z0-9])+\.[a-z]{2,9}$"`;do
       		nameserver=`dig NS $domain|sed -r -n "/IN\sNS/p"|grep -v "^;"|head -1|awk '{print $5}'|sed 's/.$//'|tr "[:upper:]" "[:lower:]"`
      		for (( i=1; i <= ${#nsarray[@]}; i++ )); do
               		if [[ ${nsarray[$i]} == $nameserver ]]; then
                       		hasnameserver=1
               		fi
       		done
       		if [[ $hasnameserver -ne 1 ]]; then
               		echo $domain
               		echo $domain >> $path/full-migration/remote_dns
              		#echo "Whois information for $domain" >> $path/remote_dns
               		#whois $domain|grep "Name Server:" >> $path/remote_dns
       		fi
       		hasnameserver=0
	done
	# If remote nameservers are found, inform admin
	if [[ -f $path/full-migration/remote_dns ]]; then
	        menu_prep
        	export text1="################## Initial Migration To Destination Server ###################"
        	export text2="The Following Domains Are Using Remote Nameservers:"
        	$path/full-migration/menu_templates/submenu.sh
        	sleep 2
		for each in `cat $path/full-migration/remote_dns`;do echo "Whois information for $each";whois $each|grep "Name Server:"|tr -d [:blank:];nameserver=$(whois $each|grep "Name Server:"|head -n1|tr -d [:blank:]|cut -d ':' -f2|cut -d ' ' -f2);echo "Dig information for $each @ $nameserver";dig $each @$nameserver|grep $each|grep -vw 'NS'|grep -vw 'ns1'|grep -vw 'ns2'|grep -vw 'DiG'|tail -1;echo;sleep 1;done
        	cat $path/full-migration/remote_dns
        	echo
		echo
        	read -p "Copy this list of domains to the ticket if necessary. 
                 	 Otherwise, it is available at $path/full-migration/remote_dns . 
                  	 Press any key to continue..."
        	echo
	fi
}

# Optional update for rsync. (borrowed from eugene's script for now)
rsync_update () {
	menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Updating Rsync ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
        LOCALCENT=`cat /etc/redhat-release|awk '{print $3}'|cut -d '.' -f1`
        REMOTECENT=`ssh -p$destinationPORT $destinationUSER@$destinationIP "cat /etc/redhat-release"|awk '{print $3}'|cut -d '.' -f1`
        LOCALARCH=`uname -i`
        REMOTEARCH=`ssh -p$destinationPORT $destinationUSER@$destinationIP "uname -i"`
        rpm -Uvh http://migration.sysres.liquidweb.com//rsync/rsync-3.0.0-1.el$LOCALCENT.rf.$LOCALARCH.rpm
        ssh -p$destinationPORT $destinationUSER@$destinationIP "rpm -Uvh http://migration.sysres.liquidweb.com/rsync/rsync-3.0.0-1.el$REMOTECENT.rf.$REMOTEARCH.rpm"
	echo
	echo
	echo "Rsync update complete."
}

# Version checking. This is just an idea section for now, that will need to be written still.
# May or may not be included with finished version.
# Needs expanding. Show admin the differences between the two, and also place results in a file.
versions () {
	echo
	echo "Server Versions"
	echo
	mysql_version=$(mysql --version|cut -d ',' -f1|cut -d ' ' -f6)
	echo "Mysql $mysql_version"
	echo
	php_version=$(php -v|grep built|cut -d ' ' -f2)
	echo "PHP $php_version"
	echo
}

# Copies over EA configuration, cpanel packages and features
match () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Matching EA Config, Cpanel Packages and Features ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	#EA config, Cpanel packages, Cpanel features
	rsync -avHl -e "ssh -p$destinationPORT" /var/cpanel/easy/apache/ $destinationUSER@$destinationIP:/var/cpanel/easy/apache/
	rsync -avHl -e "ssh -p$destinationPORT" /var/cpanel/packages/ $destinationUSER@$destinationIP:/var/cpanel/packages/
	rsync -avHl -e "ssh -p$destinationPORT" /var/cpanel/features/ $destinationUSER@$destinationIP:/var/cpanel/features/

	# Alternate method using yaml files(needs testing)
	#cp /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/custom/user_custom.yaml
	#rsync -avHl -e "ssh -p$destinationPORT" /var/cpanel/easy/apache/profile/custom/user_custom.yaml $destinationUSER@$destinationIP:/var/cpanel/easy/apache/profile/custom/ --progress
	# Starts easy apache in detached screen on destination server 
	rsync -avHl -e "ssh -p$destinationPORT" $path/full-migration/scripts/easy_apache.sh $destinationUSER@$destinationIP:/home/temp/ --progress
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
screen -S "easy_apache" -d -m /home/temp/easy_apache.sh
exit
EOF
	# Inform admin
	echo
	echo
	echo "Easy Apache started on destination server..."
	echo
	sleep 2
}
# ^Should check PHP version when done to verify
# php -v|head -n1|cut -d ' ' -f2|tr -d [:blank:]

# Package up cpanel accounts
package () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Packaging Accounts ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	# Move any existing cpmove files in /home out of the way
	if [[ -f /home/cpmove-*.tar ]]; then
		mkdir /home/old-cpmove
		for each in `\ls /home|egrep 'cpmove.*tar$'|cut -d '-' -f2|cut -d '.' -f1`;do mv /home/cpmove-$each.tar /home/old-cpmove/;done
	fi
	# Package accounts
	# If no conflicts, package all accounts
	if [[ -z $path/full-migration/preliminary/user_conflicts ]]; then
		for each in `\ls -A1 /var/cpanel/users/`;do /scripts/pkgacct --skiphomedir --nocompress $each /home cpmove 2>&1|tee $path/full-migration/scripts/logs/pkgacct.log;done
	else
		# Grab choice set earlier by tech in preliminary function
		override=$(cat $path/full-migration/preliminary/conflict_override)
		# If there are conflicts recorded, and tech did not set override, then make list exluding users with conflicts.
		if [[ -n $path/full-migration/preliminary/user_conflicts ]] && [[ override != $override ]]; then 
			# Make list excluding user conflicts
			echo
			echo "Creating user list excluding accounts with conflicts ..."
			for each in `\ls -A1 /var/cpanel/users`; do
				conflict=$(cat $path/full-migration/preliminary/user_conflicts|grep $each)
				if [[ $each == $conflict ]]; then
					echo
					echo "Account $each will not be included in the initial migration"
				else
					echo $each >> $path/full-migration/preliminary/userlist_exclude
					echo
					echo "Account $each added to initial migration list"
				fi
			done
			# Package accounts using created list
			for each in `cat $path/full-migration/preliminary/userlist_exclude`;do /scripts/pkgacct --skiphomedir --nocompress $each /home cpmove 2>&1|tee $path/full-migration/scripts/logs/pkgacct.log;done
		else
			# Tech did override, package all accounts
			if [[ $override == override ]]; then
				for each in `\ls -A1 /var/cpanel/users/`;do /scripts/pkgacct --skiphomedir --nocompress $each /home cpmove 2>&1|tee $path/full-migration/scripts/logs/pkgacct.log;done
			fi
		fi
	fi
	# Inform admin
	echo
	echo
	echo "Cpanel accounts have been packaged up"
	sleep 2
	echo
}

# Copy the cpmove files to the destination server
copy () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Copying Cpmove Files to Destination Server ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	rsync -avHl -e "ssh -p $destinationPORT" /home/cpmove-*.tar $destinationUSER@$destinationIP:/home/ --progress 2>&1|tee $path/full-migration/scripts/logs/cpmove.log
	echo
	echo
	echo "Cpmove files copied to destination server."
	sleep 2
	echo
}

# Checks status of easy apache started earlier on remote server, and watches until complete (if still running)
easyapache () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Checking to See If EA is Finished on Destination Server ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	rsync -avHl -e "ssh -p $destinationPORT" $path/full-migration/scripts/easy_watcher.sh $destinationUSER@$destinationIP:/home/temp/ --progress	
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
/home/temp/easy-watcher.sh
exit
EOF
	
	#echo "Waiting for EA to complete on destination server before continuing..."
	# Maybe check EA log file for that days date, or the most recent one, and check for the "success" at the end
	# Can also check via ps aux. Maybe both, to make sure it completed properly
	echo
	echo
	echo "Easy Apache complete on destination server"
	echo
}

# Restores Cpmove files on destination server
restore () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Restoring Cpmove Files on Destination Server ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	# Copies over the scripts required to run the restore and watch it
	rsync -avHlq -e "ssh -p $destinationPORT" $path/full-migration/scripts/restore-accounts.sh $destinationUSER@$destinationIP:/home/temp/
	rsync -avHlq -e "ssh -p $destinationPORT" $path/full-migration/scripts/restore-watcher.sh $destinationUSER@$destinationIP:/home/temp/
	# Watches restore process and keeps admin informed of its progress
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
screen -S "restore" -d -m /home/temp/restore-accounts.sh
/home/temp/restore-watcher.sh
exit
EOF
	# check number of accounts on both, to make sure they match
	echo
	echo
	echo "Cpmove files successfully restored on destination server"
	echo
}

# Rsync over the home directories
homedirs () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Copying Over Home Directories ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	# No conflicts, rsync all homedirs
	if [[ -z $path/full-migration/preliminary/user_conflicts ]]; then
		for each in `\ls -A /var/cpanel/users`;do rsync -avHl -e "ssh -p $destinationPORT" /home/$each/ $destinationUSER@$destinationIP:/home/$each/ --progress;done
	else
                # Grab choice set earlier by tech in preliminary function
                override=$(cat $path/full-migration/preliminary/conflict_override)
                # If there are conflicts recorded, and tech did not set override, then rsync homedirs with conflict accounts excluded
                if [[ -n $path/full-migration/preliminary/user_conflicts ]] && [[ override != $override ]]; then
			for each in `cat $path/full-migration/preliminary/userlist_exclude`;do rsync -avHl -e "ssh -p $destinationPORT" /home/$each/ $destinationUSER@$destinationIP:/home/$each/ --progress;done
		else
			# If tech decided to override, rsync all homedirs
			if [[ $override == override ]]; then
				for each in `\ls -A /var/cpanel/users`;do rsync -avHl -e "ssh -p $destinationPORT" /home/$each/ $destinationUSER@$destinationIP:/home/$each/ --progress;done
			fi
		fi
	fi
	echo
	echo
	echo "Home directories have finished copying"
	echo
}

# Sets up the destination server for testing, and provides details to admin
testing () {
        menu_prep
        export text1="################## Initial Migration To Destination Server ###################"
        export text2="Preparing Destination Server For Testing Phase ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
	# Copy over testing phase script
	rsync -avHlq -e "ssh -p$destinationPORT" $path/full-migration/scripts/testing-phase.sh $destinationUSER@$destinationIP:/home/temp/
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
screen -S "testing" -d -m /home/temp/testing-phase.sh
exit
EOF
	# Provide URLs to admin
	echo
	echo
	echo "Here is the URL for customer to paste into their hosts file: "
	echo
	echo "http://"$destinationIP"/hosts_file_entries.html"
	echo
	echo "Here is the URL so the customer can easily check their main sites via the lwtest.html"
	echo
	echo "http://"$destinationIP"/migration_test_urls.html"
	echo
	read -p "Go ahead and copy these URLs to the ticket for later reference, and to provide to the customer
		 Press any key to continue..."	
}

# Need a check on the number of accounts, to verify that at least they all restored

source ~/.bash_profile 2>&1 >/dev/null

# Options menu using dialog (ncurses utility for bash)
cmd=(dialog --separate-output --checklist "Select Migration Options:" 22 76 16)
options=(1 "System Information" off    # any option can be set to default to "on"
         2 "Pre-migration Checks" off
	 3 "Lower TTLs" on
         4 "Setup Nameservers" on
         5 "Check Versions" off
	 6 "Match Easy Apache Configuration" on
	 7 "Package Accounts" on
	 8 "Copy Packaged Accounts" on
	 9 "Restore Accounts" on
	10 "Rsync Home Directories" on
	11 "Setup Target Server For Testing Phase" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            system_info
            ;;
	2)
	    preliminary
	    ;;
        3)
            ttls
            ;;
        4)
            nameservers
            ;;
        5)
            versions
            ;;
	6)
	    match
	    ;;
	7)
	    package
	    ;;
	8)
	    copy
	    ;;
	9)
	    restore
	    ;;
	10)
	    homedirs
	    ;;
	11)
	    testing
	    ;;
    esac
done

# Script End. Returns to starter.sh
