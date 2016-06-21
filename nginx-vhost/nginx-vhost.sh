#!/bin/bash
USER_DIR='/Users/ruscon'
DOMAIN=''
USER_TRUNC=''
DOMAIN_TRUNC=''
DB_PASS=''

RET=''
function sanity_check {
	if [ "$(id -u)" != "0" ]; then
		echo "Script must be run as root."
		exit 1
	fi

#	egrep "^$USERNAME:" /etc/passwd >/dev/null
#	if [ $? -eq 0 ]; then
#		echo "$USERNAME exists!"
#		exit 3
#	fi

#	if [ ! -e /root/mysql ]; then
#		echo "Root MySQL password file missing. Please run create the file /root/mysql,"
#		echo "And put your root password as the first and only line."
#		exit 4
#	fi
}
#
#function password {
#	RET=$(cat /dev/urandom | tr -cd [:alnum:] | head -c ${1:-16})
#}
#
#function setup_user {
#	useradd -m -d $USER_DIR/$USERNAME -U $USERNAME
#
#	password
#	PASSWORD=$RET
#	echo "$USERNAME:$PASSWORD" | chpasswd
#
#	mkdir -p $USER_DIR/$USERNAME/$DOMAIN/htdocs
#	mkdir $USER_DIR/$USERNAME/$DOMAIN/logs
#	touch $USER_DIR/$USERNAME/$DOMAIN/logs/access.log
#	touch $USER_DIR/$USERNAME/$DOMAIN/logs/error.log
#	chown -R $USERNAME $USER_DIR/$USERNAME
#	chgrp -R $USERNAME $USER_DIR/$USERNAME
#
#	echo "Create user: $USERNAME with password: $PASSWORD"
#}
function php_pool {
#	if [ ! -f /etc/php5/fpm/port ]; then
#		echo "Cannot access /etc/php5/fpm/port"
#		exit 2
#	fi
#
#	# Grab the port from file, and increment.
#	PORT=$(cat /etc/php5/fpm/port)
#	echo $(($PORT + 1)) > /etc/php5/fpm/port

	cp pool.template /usr/local/etc/php/5.4/fpm.d/$PROJECT.conf
	sed -i.tmp "s|example.com|$DOMAIN|g" /usr/local/etc/php/5.4/fpm.d/$PROJECT.conf
	rm /usr/local/etc/php/5.4/fpm.d/$PROJECT.conf.tmp

#	sed -i "s|PORT|$PORT|" /usr/local/etc/php/5.4/fpm.d/$DOMAIN
#	sed -i "s|user = example|user = $USERNAME|" /usr/local/etc/php/5.4/fpm.d/$DOMAIN
#	sed -i "s|group = example|group = $USERNAME|" /usr/local/etc/php/5.4/fpm.d/$DOMAIN
	echo "Added $DOMAIN to the PHP pool"
}

function nginx_vhost {
	cp vhost.template /usr/local/etc/nginx/sites-available/$DOMAIN
	sed -i.tmp "s|example.com|$DOMAIN|g" /usr/local/etc/nginx/sites-available/$DOMAIN
	rm /usr/local/etc/nginx/sites-available/$DOMAIN.tmp
#	sed -i "s|username|$USERNAME|g" /usr/local/etc/nginx/sites-available/$DOMAIN
#	sed -i "s|PORT|$PORT|g" /usr/local/etc/nginx/sites-available/$DOMAIN
	# Should probably sed through and replace /ebs/www with $USER_DIR

	# Enable the site
	ln -s /usr/local/etc/nginx/sites-available/$DOMAIN /usr/local/etc/nginx/sites-enabled/$DOMAIN

	mkdir "$USER_DIR/projects/$PROJECT"
	chown ruscon:staff "$USER_DIR/projects/$PROJECT"
	ln -s $USER_DIR/projects/$PROJECT /usr/local/var/www/$DOMAIN

	echo "Enabled $DOMAIN in the web server"
}

function ect_host {
	echo "127.0.0.1       $DOMAIN" >> /etc/hosts
}

#function server_reload {
#	/etc/init.d/php5-fpm reload
#	/etc/init.d/nginx reload
#	echo "Servers reloaded"
#}
#function prepare_mysql {
#	# Generate dbuser password
#	password
#	DB_PASS=$RET
#
#	# Truncate username (15 chars max) and dbname (63 chars max)
#	USER_TRUNC=$(echo $USERNAME | cut -c1-15)
#
#	# This should be a separate user with only create perms.
#	echo "CREATE DATABASE $USER_TRUNC;
#GRANT ALL PRIVILEGES ON $USER_TRUNC.* to '$USER_TRUNC'@'localhost' IDENTIFIED BY '$DB_PASS';" > $USERNAME.sql
#	mysql -u root -p$(cat /root/mysql) < $USERNAME.sql
#	rm $USERNAME.sql
#	echo "Created MySQL user: $USER_TRUNC password: $DB_PASS database: $DOMAIN_TRUNC"
#}

#function add_to_ftp {
#	usermod -g proftpd $USERNAME
#}

#function install_wordpress {
#	wget http://wordpress.org/latest.tar.gz
#	tar xf latest.tar.gz
#	mv wordpress/* $USER_DIR/$USERNAME/$DOMAIN/htdocs/
#	cp $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config-sample.php $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#	sed -i "s|database_name_here|$USER_TRUNC|g" $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#	sed -i "s|username_here|$USERNAME|g" $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#	sed -i "s|password_here|$DB_PASS|g" $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#
#	echo "	define(\"FTP_HOST\", \"$DOMAIN\");
#	define(\"FTP_USER\", \"$USERNAME\");
#	define(\"FTP_PASS\", \"$USERPASS\");" >> $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#
#	# Add in salts from the wordpress salt generator
#	wget https://api.wordpress.org/secret-key/1.1/salt/
#	sed -i "s/|/a/g" index.html
##	cat index.html | while read line; do
##   	sed -i "s|define('.*',.*'put your unique phrase here');|$line|" $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
##	sed 1d $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
##	done
#	sed -i '/#@-/r index.html' $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#	sed -i "/#@+/,/#@-/d" $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#	rm index.html
#	rm latest.tar.gz
#
#	# Add in FTP stuff, even though that's not defined yet..
#
#	# Own these new files
#	chown -R $USERNAME $USER_DIR/$USERNAME/$DOMAIN/htdocs/*
#	chgrp -R $USERNAME $USER_DIR/$USERNAME/$DOMAIN/htdocs/*
#	# Make sure no one else can read this file
#	chmod 700 $USER_DIR/$USERNAME/$DOMAIN/htdocs/wp-config.php
#
#	#echo "Wordpress for $DOMAIN installed."
#	#echo "Visit http://$DOMAIN/wp-admin/install.php to complete installation"
#}

##############################################################################
# Start of program
#USERNAME=$1
PROJECT=$1
DOMAIN="$1.dev"

sanity_check $#
#setup_user
php_pool
nginx_vhost
ect_host
#server_reload
#prepare_mysql
#add_to_ftp
#install_wordpress
exit 0
