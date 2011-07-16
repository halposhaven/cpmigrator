#!/bin/bash

source ~/.bash_profile
TERM=linux

unalias ls 2> /dev/null

if [[ -d /home/cprestoretemp ]]; then
	# Might want to have a check here for cpmove files not a part of this migration, and then move them into this dir.
	echo "Directory Exists"
else
	mkdir /home/cprestoretemp
fi

for each in `ls /home |grep 'cpmove-'| cut -d '-' -f2 | cut -d '.' -f1`; do /scripts/restorepkg /home/cpmove-$each.tar; mv /home/cpmove-$each.tar /home/cprestoretemp; done
