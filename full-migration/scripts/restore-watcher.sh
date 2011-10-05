#!/bin/bash

total=$(\ls -A1 /home|grep cpmove-|wc -l)
LOOP=0
echo

while [ $LOOP == 0 ]
do
	pid=$(screen -ls|grep restore|tr -d [:space:]|cut -d '.' -f2|cut -d '(' -f1)
	if [[ $pid == restore ]]; then
        	date=$(date +"%m-%d-%y.%T")
		so_far=$(\ls -A1 /var/cpanel/users|wc -l)
		echo "$so_far out of $total accounts restored. Time: $date"
        	sleep 15
	else
		LOOP=1
	fi
done

exit
