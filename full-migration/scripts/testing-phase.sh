#!/bin/bash

unalias ls 2> /dev/null

# If these files already exist, remove them
[ -f /usr/local/apache/htdocs/hosts_file_entries.html ] && rm -f /usr/local/apache/htdocs/hosts_file_entries.html
[ -f /usr/local/lp/htdocs/hosts_file_entries.html ] && rm -f /usr/local/lp/htdocs/hosts_file_entries.html

# Create accessible page for hosts file entries. (credit to jpurkis on this)
cat /etc/userdatadomains|sed -e 's/:/ /g' -e 's/==/ /g'|while read sdomain user owner type maindomain docroot ip port;do echo "<br>"$ip $sdomain "www."$sdomain >> /usr/local/apache/htdocs/hosts_file_entries.html;done && \cp /usr/local/apache/htdocs/hosts_file_entries.html /usr/local/lp/htdocs/

# Add lwtest.html files to all primary accounts
for each in `ls -A1 /var/cpanel/users`;do echo "<html><body><h1>This is the new server</h1>" > /home/$each/public_html/lwtest.html;chown $each:$each /home/$each/public_html/lwtest.html;done

# Grab all primary domains and create URL's that include the /lwtest.html on the end. Accessible to customer.
for each in `cat /etc/trueuserdomains|cut -d ':' -f1|sort`; do echo $each|sed 's/$/\/lwtest.html/' >> /usr/local/apache/htdocs/migration_test_urls.html;echo "<br>" >> /usr/local/apache/htdocs/migration_test_urls.html;done && \cp /usr/local/apache/htdocs/migration_test_urls.html /usr/local/lp/htdocs/
