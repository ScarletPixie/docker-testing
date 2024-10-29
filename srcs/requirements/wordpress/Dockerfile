FROM	alpine:3.19.4


#	get wordpress and wordpress cli
RUN	mkdir -p /var/www/html/
WORKDIR	/var/www/html
ADD	https://wordpress.org/latest.zip https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /var/www/html/


#	set envs
ARG	DOMAIN_NAME_ARG
ARG	WP_TITLE_ARG
ARG	WP_USERS_ARG
ARG	DB_USER_ARG
ARG	DB_HOST_ARG
ENV	DOMAIN_NAME=${DOMAIN_NAME_ARG} WP_TITLE=${WP_TITLE_ARG}	WP_USERS=${WP_USERS_ARG} DB_USER=${DB_USER_ARG} DB_HOST=${DB_HOST_ARG}


#	copy scripts
COPY tools/test_environment.sh /root/
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN	chmod +x /root/test_environment.sh /usr/local/bin/entrypoint.sh


#	check if all necessary data is present
RUN	--mount=type=secret,id=wp_admin_name \
	--mount=type=secret,id=wp_admin_email \
	--mount=type=secret,id=wp_admin_password \
	--mount=type=secret,id=wp_user_name \
	--mount=type=secret,id=wp_user_email \
	--mount=type=secret,id=wp_user_password \
	--mount=type=secret,id=db_user_password \
	/root/test_environment.sh

#	install necessary packages
RUN	apk update && apk upgrade && apk add --no-cache php82-fpm wget php php-phar php-mysqli php-mbstring php-gd

#	accept non localhost connections and delete user/group directive
RUN	sed -i "s|listen =.*|listen = 0.0.0.0:9000|" /etc/php82/php-fpm.d/www.conf && \
	sed -i "/group = nobody/d" /etc/php82/php-fpm.d/www.conf && sed -i "/user = nobody/d" /etc/php82/php-fpm.d/www.conf

#	create non root user anse set necessary permissions
EXPOSE		9000
RUN			adduser --ingroup www-data -DH www-data && chown -R www-data:www-data /var/log/php82/ /var/www/html/ /etc/php82/php-fpm.d/
USER		www-data
RUN			unzip latest.zip; rm latest.zip; mv wp-cli.phar wordpress
ENTRYPOINT	[ "entrypoint.sh" ]