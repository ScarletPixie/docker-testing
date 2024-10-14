#!/bin/sh

set -e

#	get wordpress and wordpress cli
if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
	cd /var/www/html
	#rm -rf wordpress
	apk add --no-cache wget php php-phar php-mysqli php-mbstring #	for some reason the pre installed wget is not working
	wget https://wordpress.org/latest.zip
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	unzip latest.zip
	rm -rf latest.zip
	mv wp-cli.phar wordpress

	chown -R www-data:www-data /var/www/html

	cd wordpress
	php wp-cli.phar config create --dbname=wordpress --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="inception_mariadb"
	php wp-cli.phar core install --url=localhost --title="WP-CLI" --admin_user=wpcli --admin_password=wpcli --admin_email=info@wp-cli.org
	#cp wp-config-sample.php wp-config.php
fi

unset MYSQL_PASSWORD
exec "php-fpm82" "--nodaemonize"