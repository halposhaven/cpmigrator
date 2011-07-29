#!/bin/bash

LOOP=0
echo

while [ $LOOP == 0 ]
do
	pid=$(screen -ls|grep restore_dbs|tr -d [:space:]|cut -d '.' -f2|cut -d '(' -f1)
	if [[ $pid == restore_dbs ]]; then
        	date=$(date +"%m-%d-%y.%T")
		echo "Databases are still restoring: $date"
        	sleep 15
	else
		LOOP=1
	fi
done

exit
