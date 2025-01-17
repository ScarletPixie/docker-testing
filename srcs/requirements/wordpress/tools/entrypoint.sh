#!/bin/sh

set -e
cd /var/www/html/wordpress

#	get wordpress and wordpress cli
if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
	WP_ADMIN_NAME="$(cat /run/secrets/wp_admin_name)"
	WP_ADMIN_EMAIL="$(cat /run/secrets/wp_admin_email)"
	WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
	WP_USER_NAME="$(cat /run/secrets/wp_user_name)"
	WP_USER_EMAIL="$(cat /run/secrets/wp_user_email)"
	WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"
	DB_PASSWORD="$(cat /run/secrets/db_user_password)"

	php wp-cli.phar config create --dbname=wordpress --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="inception-mariadb"
	php wp-cli.phar core install --url="https://$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --skip-email
	php wp-cli.phar user create "$WP_USER_NAME" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD"
fi

exec "php-fpm83" "--nodaemonize"