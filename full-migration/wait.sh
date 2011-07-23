#!/bin/bash

SUBLOOP=0
while [ SUBLOOP == 0 ]
do
	if [ -z $CONTINUE ]; then
		for each in text{1..6};do unset $each;done
		clear
		export text1="The initial migration has been completed, and the migration is now paused."
		export text2="To begin the final sync, please type 'continue'"
		echo
		echo
		echo -n "Type 'continue' to begin the final sync:"
		read CONTINUE
			if [ $CONTINUE == continue ]; then
				echo
				echo "Now starting final sync ..."
				sleep 2
				SUBLOOP=1
			else
				echo
				echo "ERROR: Unknown input!"
				SUBLOOP=0
			fi
		SUBLOOP=0
		sleep 24h
	fi
done
