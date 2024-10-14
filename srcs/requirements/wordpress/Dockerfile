FROM	alpine:3.19.4

#	copy scripts
COPY tools/install_wordpress.sh /root/
COPY tools/test_environment.sh /root/
COPY tools/entrypoint.sh /root/
RUN	chmod +x /root/install_wordpress.sh
RUN	chmod +x /root/test_environment.sh
RUN	chmod +x /root/entrypoint.sh

#	define env variables
ARG	MYSQL_USER_ARG
ARG MYSQL_PASSWORD_ARG

ENV	MYSQL_PASSWORD=$MYSQL_PASSWORD_ARG
ENV	MYSQL_USER=$MYSQL_USER_ARG

RUN	/root/test_environment.sh

#	install necessary packages
RUN	apk update && apk upgrade && apk add php82-fpm

#	create non root user
RUN	adduser --ingroup www-data -DH www-data
RUN	mkdir -p /var/www/html/
RUN	chown -R www-data:www-data /var/log/php82/
RUN	chown -R www-data:www-data /var/www/html/

#	accept non localhost connections
RUN	sed -i '/listen =.*/c\listen = 0.0.0.0:9000' /etc/php82/php-fpm.d/www.conf

#	get wordpress
#RUN	/root/install_wordpress.sh

EXPOSE 9000
#USER	www-data

ENTRYPOINT [ "/root/entrypoint.sh" ]
#CMD [ "php-fpm82", "--nodaemonize" ]