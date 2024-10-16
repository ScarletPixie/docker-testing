FROM	alpine:3.19.4

#	get wordpress and wordpress cli
RUN	mkdir -p /var/www/html/
WORKDIR	/var/www/html
ADD	https://wordpress.org/latest.zip /var/www/html
ADD	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /var/www/html
RUN	unzip latest.zip && rm latest.zip && chmod +x wp-cli.phar && mv wp-cli.phar wordpress

#	copy scripts
COPY tools/test_environment.sh /root/
COPY tools/entrypoint.sh /usr/bin/entrypoint
RUN	chmod +x /root/test_environment.sh
RUN	chmod +x /usr/bin/entrypoint

#	mariadb
ARG	MYSQL_USER_ARG
ARG	MYSQL_PASSWORD_ARG

#	wp admin
ARG	WP_ADMIN_ARG
ARG	WP_ADMIN_EMAIL_ARG
ARG	WP_ADMIN_PASSWORD_ARG

#	website settings
ARG	WP_TITLE_ARG
ARG	DOMAIN_NAME_ARG

#	non admin wp user
ARG	WP_USER_ARG
ARG	WP_EMAIL_ARG
ARG	WP_PASSWORD_ARG

#	define env vars and store password
ENV WP_TITLE=$WP_TITLE_ARG
ENV DOMAIN_NAME=$DOMAIN_NAME_ARG
ENV	MYSQL_USER=$MYSQL_USER_ARG
ENV	WP_ADMIN=$WP_ADMIN_ARG
ENV	WP_ADMIN_EMAIL=$WP_ADMIN_EMAIL_ARG
ENV	WP_USER=$WP_USER_ARG
ENV	WP_EMAIL=$WP_EMAIL_ARG

#	sensitive data
RUN	echo "${MYSQL_PASSWORD_ARG}" > /tmp/mysql_password
RUN	echo "${WP_ADMIN_PASSWORD_ARG}" > /tmp/wp_admin_password
RUN	echo "${WP_PASSWORD_ARG}" > /tmp/wp_password

#	check if all necessary data is present
RUN	/root/test_environment.sh

#	install necessary packages
RUN	apk update && apk upgrade && apk add php82-fpm wget php php-phar php-mysqli php-mbstring

#	accept non localhost connections and delete user/group directive
RUN sed -i "s|listen =.*|listen = 0.0.0.0:9000|" /etc/php82/php-fpm.d/www.conf
RUN sed -i "/group = nobody/d" /etc/php82/php-fpm.d/www.conf
RUN sed -i "/user = nobody/d" /etc/php82/php-fpm.d/www.conf

#	create non root user anse set necessary permissions
RUN	adduser --ingroup www-data -DH www-data
RUN	chown -R www-data:www-data /var/log/php82/
RUN	chown -R www-data:www-data /var/www/html/
RUN	chown -R www-data:www-data /tmp/
RUN	chmod -R 777 /tmp

#	init
USER	www-data
EXPOSE	9000
ENTRYPOINT	[ "entrypoint" ]