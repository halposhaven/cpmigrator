#!/bin/bash

unalias ls 2> /dev/null

# If these files already exist, remove them
[ -f /usr/local/apache/htdocs/hosts_file_entries.html ] && rm -f /usr/local/apache/htdocs/hosts_file_entries.html
[ -f /usr/local/apache/htdocs/migration_test_urls.html ] && rm -f /usr/local/apache/htdocs/migration_test_urls.html
[ -f /home/temp/testing_errors.txt ] && rm -f /home/temp/testing_errors.txt

# Create accessible page for hosts file entries. (credit to jpurkis on this)
if [[ -f /etc/userdatadomains ]]; then
	cat /etc/userdatadomains|sed -e 's/:/ /g' -e 's/==/ /g'|while read sdomain user owner type maindomain docroot ip port;do echo "<br>"$ip $sdomain "www."$sdomain >> /usr/local/apache/htdocs/hosts_file_entries.html;done
else
	echo "Problem found. /ect/userdatadomains not found. Trying to fix ..."
	/scripts/upcp --force > /dev/null 2>&1
	if [[ -f /etc/userdatadomains ]]; then
		echo "Problem fixed. Creating hosts file page ..."
		sleep 2
		cat /etc/userdatadomains|sed -e 's/:/ /g' -e 's/==/ /g'|while read sdomain user owner type maindomain docroot ip port;do echo "<br>"$ip $sdomain "www."$sdomain >> /usr/local/apache/htdocs/hosts_file_entries.html;done
	else
		echo "Problem not fixed. Unable to create hosts file entries."
		echo "/etc/userdatadomains does not exist. Hosts entries not created." >> /home/temp/testing_errors.txt
	fi
fi

# Add lwtest.html files to all primary accounts
for each in `ls -A1 /var/cpanel/users`;do echo "<html><body><h1>This is the new server</h1>" > /home/$each/public_html/lwtest.html;chown $each:$each /home/$each/public_html/lwtest.html;done

# Grab all primary domains and create URL's that include the /lwtest.html on the end. Accessible to customer.
if [[ -f /etc/trueuserdomains ]]; then
	for each in `cat /etc/trueuserdomains|cut -d ':' -f1|sort`; do echo $each|sed 's/$/\/lwtest.html/' >> /usr/local/apache/htdocs/migration_test_urls.html;echo "<br>" >> /usr/local/apache/htdocs/migration_test_urls.html;done
else
	echo "/etc/trueuserdomains does not exist. Test URLs not created." >> /home/temp/testing_errors.txt
fi
