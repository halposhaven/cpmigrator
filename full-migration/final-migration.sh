#!/bin/bash

unalias ls 2> /dev/null

path=`pwd`

# Set destination server variables
destinationIP=$(cat $path/full-migration/destination-files/destinationIP)
destinationPASS=$(cat $path/full-migration/destination-files/destinationPASS)
destinationPORT=$(cat $path/full-migration/destination-files/destinationPORT)
destinationUSER=$(cat $path/full-migration/destination-files/destinationUSER)

disable_services (){
	for each in text{1..6};do unset $each;done
	clear
	export text1="Temporarily disabling services on source server ..."
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
	test -d /home/dbdumps && mv /home/dbdumps{,.`date +%F`.bak}
	mkdir /home/dbdumps
	for db in `mysql -Ns -e "show databases"|egrep -v "test|information_schema|cphulkd|eximstats|horde|leechprotect|modsec|mysql|roundcube|^test$"`;do echo $db;mysqldump $db > /home/dbdumps/$db.sql;done
	# Copy the databases
	for each in text{1..6};do unset $each;done
	clear
	export text1="Copying the database dumps to the destination server ..."
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
test -d /home/dbdumps && mv /home/dbdumps{,.`date +%F`.bak}
EOF
	rsync -avHP -e 'ssh -p$destinationPORT' /home/dbdumps root@$destinationIP:/home/
}

homedirs () {
	# This needs to either split into a separate process, or run in another screen session, so the databases can be restored while this is running
	for each in `\ls -A /var/cpanel/users`; do rsync -avHP -e 'ssh -pdestinationPORT' /home/$each/ root@$destinationIP:/home/$each/ --update; done
	rsync -avHP -e 'ssh -p$destinationPORT' /usr/local/cpanel/3rdparty/mailman root@$destinationIP:/usr/local/cpanel/3rdparty/
	rsync -avHP -e 'ssh -pdestinationPORT' /var/spool root@$destinationIP:/var/
}

restore_dbs () {
	ssh -Tq $destinationUSER@$destinationIP -p$destinationPORT /bin/bash <<EOF
cd /home/dbdumps
test -d /home/prefinalsyncdbs && mv /home/prefinalsyncdbs{,.`date +%F`.bak}
mkdir /home/prefinalsyncdbs
screen -S "restore_dbs" -d -m `for each in *.sql;do echo ${each%.*};mysqldump ${each%.*} > /home/prefinalsyncdbs/$each;mysql ${each%.*} < /home/dbdumps/$each;done`
exit
EOF
# Once this finishes (monitor), return view to rsyncing homedirs (might need multiple sub processes) 
}

forward () {
	/etc/init.d/named stop
	mv /var/named{,.`date +%H%M`.bak}
	mkdir /var/named
	chown root:named /var/named
	rsync -avHP -e 'ssh -p$destinationPORT' root@$destinationIP:/var/named/ /var/named/
	/etc/init.d/named start
	rndc reload
}

remove_dumps () {
	rm -f /home/dbdumps/*
	rmdir /home/dbdumps
}

restart_services () {
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
         3 "Rsync home directories" on
	 4 "Restore databases" on
         5 "Forward DNS from source server to destination server" on
         6 "Remove database dumps" on
         7 "Restart source server services" on
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
            homedirs
            ;;
	4)
	    restore_dbs
	    ;;
        5)
            forward
            ;;
        6)
            remove_dumps
            ;;
        7)
            restart_services
            ;;
    esac
done

