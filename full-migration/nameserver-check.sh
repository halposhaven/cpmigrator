#!/bin/bash

# Check with mjones. He worked on making this more reliable at one point

echo "Checking for remote nameservers..."
echo

path=`pwd`

[ -f $path/remote_dns ] && rm -f $path/remote_dns

counter=1
for ns in `cat /etc/nameserverips | cut -d '=' -f2`; do
       nsarray[$counter]=`echo $ns | tr "[:upper:]" "[:lower:]"`
       counter=`expr $counter + 1`
done

for domain in `cat /etc/userdomains | grep -v \* | cut -d ':' -f1 | egrep "^[a-zA-Z0-9]([-]?[a-zA-Z0-9])+\.[a-z]{2,9}$"`; do
       nameserver=`dig NS $domain | sed -r -n "/IN\sNS/p" | grep -v "^;" | head -1 | awk '{print $5}' | sed 's/.$//' | tr "[:upper:]" "[:lower:]"`
       for (( i=1; i <= ${#nsarray[@]}; i++ )); do
               if [[ ${nsarray[$i]} == $nameserver ]]; then
                       hasnameserver=1
               fi
       done
       if [[ $hasnameserver -ne 1 ]]; then
               echo $domain
	       echo $domain >> $path/remote_dns
	       #echo "Whois information for $domain" >> $path/remote_dns
               #whois $domain|grep "Name Server:" >> $path/remote_dns
       fi
       hasnameserver=0
done

if [[ -f $path/remote_dns ]]; then
	echo "The following domains are using remote nameservers:"
	echo
	cat $path/remote_dns
	echo
	read -p "Copy this list of domains to the ticket if necessary. 
		 Otherwise, it is available at $path/remote_dns . 
                 Press any key to continue..."
	echo
fi
