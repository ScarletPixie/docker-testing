FROM	alpine:latest
RUN	apk update && apk upgrade && apk add php82-fpm

#	create non root user
RUN	adduser --ingroup www-data -DH www-data
RUN	mkdir -p /var/www/html/
RUN	chown -R www-data:www-data /var/log/php82/
RUN	chown -R www-data:www-data /var/www/html/
USER www-data

EXPOSE 9000
CMD [ "php-fpm82", "--nodaemonize" ]