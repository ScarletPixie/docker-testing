FROM	alpine:latest
RUN	apk update && apk upgrade && apk add php82-fpm

#	create non root user
RUN	adduser --ingroup www-data -DH wordpress
RUN	chown -R wordpress:www-data /var/log/php82/
USER wordpress

CMD [ "php-fpm82", "--nodaemonize" ]