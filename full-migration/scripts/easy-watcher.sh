#!/bin/bash

LOOP=0
echo

while [ $LOOP == 0 ]
do
	pid=$(screen -ls|grep easy_apache|tr -d [:space:]|cut -d '.' -f2|cut -d '(' -f1)
	if [[ $pid == easy_apache ]]; then
        	date=$(date +"%m-%d-%y.%T")
		echo "Easy Apache Still Running Time: $date"
        	sleep 60
	else
		LOOP=1
	fi
done

exit
