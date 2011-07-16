#!/bin/bash

path=`pwd`

for each in `/bin/ls -A1 /var/cpanel/users/`;do /scripts/pkgacct --skiphomedir $each /home cpmove nocompress2>&1|tee $path/full-migration/scripts/logs/pkgacct.log;done
