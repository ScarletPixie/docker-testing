#!/bin/sh

set -e
cd /var/www/html/wordpress

#	get wordpress and wordpress cli
if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
	#	get passwords
	MYSQL_PASSWORD=$(cat /tmp/mysql_password)
	WP_ADMIN_PASSWORD=$(cat /tmp/wp_admin_password)
	WP_PASSWORD=$(cat /tmp/wp_password)

	if [ -z "$MYSQL_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_PASSWORD" ]; then
		echo "missing necessary mysql_password and wp_admin_password files, rebuild please" && exit 1
	fi

	#	create wp-config.php and install wordpress
	php wp-cli.phar config create --dbname=wordpress --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="inception_mariadb"
	php wp-cli.phar core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --skip-email
	php wp-cli.phar user create "$WP_USER" "$WP_EMAIL" --role=author --user_pass="$WP_PASSWORD"
	rm wp-cli.phar
fi

#	delete password files
rm -rf /tmp/*

exec "php-fpm82" "--nodaemonize"