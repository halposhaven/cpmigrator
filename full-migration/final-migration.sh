#!/bin/bash

unalias ls 2> /dev/null

path=`pwd`

# Set destination server variables
destinationIP=$(cat $path/full-migration/destination-files/destinationIP)
destinationPASS=$(cat $path/full-migration/destination-files/destinationPASS)
destinationPORT=$(cat $path/full-migration/destination-files/destinationPORT)
destinationUSER=$(cat $path/full-migration/destination-files/destinationUSER)

disable_services (){
	# Turn off services on source server
	for each in text{1..6};do unset $each;done
	clear
	export text1="Temporarily disabling services on source server ..."
	$path/full-migration/menu_templates/submenu.sh
	sleep 2
	/usr/local/cpanel/bin/tailwatchd --disable=Cpanel::TailWatch::ChkServd
	/etc/init.d/httpd stop
	/etc/init.d/exim stop
	/etc/init.d/cpanel stop
}

databases () {
	# Will need to have an option to handle users that didn't originally copy (caught by the 'preliminary' function
	# Dump the databases
	for each in text{1..6};do unset $each;done
	clear
	export text1="Dumping the databases to /home/dbdumps ..."
	$path/full-migration/menu_templates/submenu.sh
	sleep 2
	test -d /home/dbdumps && mv /home/dbdumps{,.`date +%F`.bak}
	mkdir /home/dbdumps
	for db in `mysql -Ns -e "show databases"|egrep -v "test|information_schema|cphulkd|eximstats|horde|leechprotect|modsec|mysql|roundcube|^test$"`;do echo $db;mysqldump $db > /home/dbdumps/$db.sql;done
	# Copy the databases
	for each in text{1..6};do unset $each;done
	clear
	export text1="Copying the database dumps to the destination server ..."
	$path/full-migration/menu_templates/submenu.sh
	sleep 2
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
test -d /home/dbdumps && mv /home/dbdumps{,.`date +%F`.bak}
EOF
	rsync -avHP -e 'ssh -p$destinationPORT' /home/dbdumps root@$destinationIP:/home/
}

restore_dbs () {
        for each in text{1..6};do unset $each;done
        clear
        export text1="Starting a restore of the databases ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
        ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
cd /home/dbdumps
test -d /home/prefinalsyncdbs && mv /home/prefinalsyncdbs{,.`date +%F`.bak}
mkdir /home/prefinalsyncdbs
screen -S "restore_dbs" -d -m `for each in *.sql;do echo ${each%.*};mysqldump ${each%.*} > /home/prefinalsyncdbs/$each;mysql ${each%.*} < /home/dbdumps/$each;done`
exit
EOF
}

homedirs () {
	# This needs to either split into a separate process, or run in another screen session, so the databases can be restored while this is running
	for each in text{1..6};do unset $each;done
	clear
	export text1="Rsyncing the homedirs ..."
	$path/full-migration/menu_templates/submenu.sh
	sleep 2
	for each in `\ls -A /var/cpanel/users`;do rsync -avHP -e 'ssh -pdestinationPORT' /home/$each/ root@$destinationIP:/home/$each/ --update;done
	rsync -avHP -e 'ssh -p$destinationPORT' /usr/local/cpanel/3rdparty/mailman root@$destinationIP:/usr/local/cpanel/3rdparty/
	rsync -avHP -e 'ssh -pdestinationPORT' /var/spool root@$destinationIP:/var/
}

db_check () {
        clear
        for each in text{1..6};do unset $each;done
        export text1="Checking to see if databases have finished restoring ..."
        $path/full-migration/menu_templates/submenu.sh
        sleep 2
        rsync -avHl -e "ssh -p $destinationPORT" $path/full-migration/scripts/db-watcher.sh $destinationUSER@$destinationIP:/home/temp/ --progress
        ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
/home/temp/db-watcher.sh
exit
EOF
	echo
	echo "Databases restored."
}

forward () {
	clear
	for each in text{1..6};do unset $each;done
	export text1="Setting up DNS forwarding ..."
	$path/full-migration/menu_templates/submenu.sh
	/etc/init.d/named stop
	mv /var/named{,.`date +%H%M`.bak}
	mkdir /var/named
	chown root:named /var/named
	rsync -avHP -e 'ssh -p$destinationPORT' root@$destinationIP:/var/named/ /var/named/
	/etc/init.d/named start
	rndc reload
}

remove_dumps () {
	clear
	for each in text{1..6};do unset $each;done
	export text1="Removing Mysql dumps ..."
	$path/full-migration/menu_templates/submenu.sh
	rm -f /home/dbdumps/*
	rmdir /home/dbdumps
ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
rm -f /home/dbdumps/*
rmdir /home/dbdumps
EOF
}

restart_services () {
	clear
	for each in text{1..6};do unset $each;done
	export text1="Restarting services ..."
	$path/full-migration/menu_templates/submenu.sh
	/etc/init.d/cpanel start
	/etc/init.d/exim start
	/etc/init.d/httpd start
	/usr/local/cpanel/bin/tailwatchd --enable=Cpanel::TailWatch::ChkServd
}

source ~/.bash_profile 2>&1 >/dev/null
clear
# Options menu using dialog (ncurses utility for bash)
cmd=(dialog --separate-output --checklist "Select Final Sync Options:" 22 76 16)
options=(1 "Disable source server services" on    # any option can be set to default to "on"
         2 "Dump and copy databases" on
	 3 "Restore databases" on
         4 "Rsync home directories" on
	 5 "Verify databases have finished restoring" on
         6 "Forward DNS from source server to destination server" on
         7 "Remove database dumps" on
         8 "Restart source server services" on
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            disable_services
            ;;
        2)
            databases
            ;;
        3)
            restore_dbs
            ;;
	4)
	    homedirs
	    ;;
	5)
	    db_check
	    ;;
        6)
            forward
            ;;
        7)
            remove_dumps
            ;;
        8)
            restart_services
            ;;
    esac
done

