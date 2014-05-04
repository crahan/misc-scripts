#!/bin/bash
# Script to add a new user and Apache vhost 
#
# template file _template_
#<VirtualHost *:80>
#	ServerAdmin foo@bar.com
#	ServerName _fulldomain_
#	
#	DocumentRoot /home/_username_/www
#	<Directory />
#		Options FollowSymLinks
#		AllowOverride None
#	</Directory>
#	<Directory /home/_username_/www>
#		Options FollowSymLinks
#		AllowOverride All
#		Order allow,deny
#		Allow from all
#	</Directory>
#
#	# Possible values include: debug, info, notice, warn, error, crit, alert, emerg.
#	LogLevel warn
#	ErrorLog /var/log/apache2-vhosts/_username_/error.log
#	CustomLog /var/log/apache2-vhosts/_username_/access.log combined
#
#	# redirect non-www to www
#	RewriteEngine On
#	RewriteCond %{HTTP_HOST} ^_domain_\._ext_$ [NC]
#	RewriteRule (.*) http://www._fulldomain_$1 [L,R=301]
#</VirtualHost>

# config parameters
usershell='/bin/bash'
pwtype='MD5' # DES, MD5, SHA-256, SHA-512

# check if root is running the script
if [ $(id -u) -eq 0 ]; then
	# get input variables
	read -p "Enter username : " username
	read -p "Enter domain: " fulldomain

	# parse the domain name
	domain=`echo $fulldomain | awk -F. '{print $(NF-1)}'`
	ext=`echo $fulldomain | awk -F. '{print $(NF-0)}'`

	# check if the user doesn't exist already
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		# add a new group and user
		groupadd $username
		useradd -m -s $usershell -c $username -g $username -G group1,group2 -p `pwgen -yn 25 1 | mkpasswd -m $pwtype --stdin` $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"

		# copy files, set ownership & permission
		mkdir -p /home/$username/www /home/$username/private /home/$username/backups
		chown -R $username:$username /home/$username/
		chmod 751 /home/$username
		chown $username:www-data /home/$username/www
		chmod 750 /home/$username/www
		chmod g+s /home/$username/www
		chown $username:www-data /home/$username/private
		chmod 770 /home/$username/private
		chmod g+s /home/$username/private
		chown $username:$username /home/$username/backups
		chmod 750 /home/$username/backups

		# create new logs folder
		mkdir -p /var/log/apache2-vhosts/$username
		chown root:$username /var/log/apache2-vhosts/$username
		chmod 750 /var/log/apache2-vhosts/$username		

		# copy the vhosts template
		cp /etc/apache2/sites-available/_template_ /etc/apache2/sites-available/$username
		
		# replace the _vars_
		sed -i -e "s/_fulldomain_/$fulldomain/" /etc/apache2/sites-available/$username
		sed -i -e "s/_domain_/$domain/" /etc/apache2/sites-available/$username
		sed -i -e "s/_ext_/$ext/" /etc/apache2/sites-available/$username
		sed -i -e "s/_username_/$username/" /etc/apache2/sites-available/$username

		# add htaccess entry (only to block bots/prevent indexing)
		htpasswd /path/to/htpasswd $username "password"

		# reload Apache (no use, we need to link to sites-enabled first)
		# /usr/sbin/apache2ctl -k graceful
	fi
else
	# oops, you're not root
	echo "Only root may add a user to the system"
	exit 2
fi
