#!/bin/bash

path=`pwd`

# Destination server variables
destinationIP=$(cat $path/full-migration/destination-files/destinationIP)
destinationPORT=$(cat $path/full-migration/destination-files/destinationPORT)
destinationUSER=$(cat $path/full-migration/destination-files/destinationUSER)

rsync -avHl -e "ssh -p$destinationPORT" /home/cpmove-*.tar $destinationUSER@$destinationIP:/home/ --progress 2>&1|tee $path/full-migration/scripts/logs/cpmove.log
