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
	REDIS_PASSWORD="$(cat /run/secrets/redis_password)"

	php wp-cli.phar config create --dbname=wordpress --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="inception_mariadb"
	php wp-cli.phar core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --skip-email
	php wp-cli.phar user create "$WP_USER_NAME" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD"

	#	redis plugin
	php wp-cli.phar config set WP_REDIS_HOST 'inception_redis'
	php wp-cli.phar config set WP_REDIS_PORT 6379
	php wp-cli.phar config set WP_REDIS_PASSWORD "$REDIS_PASSWORD"  > /dev/null && echo "setting password..."
	php wp-cli.phar config set WP_REDIS_DATABASE 0
	php wp-cli.phar config set WP_CACHE_KEY_SALT "$DOMAIN_NAME"
	
	php wp-cli.phar plugin install redis-cache --activate
	php wp-cli.phar redis enable
fi

exec "php-fpm82" "--nodaemonize"