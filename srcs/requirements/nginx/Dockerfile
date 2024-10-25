FROM	alpine:3.19.4

#	install nginx
RUN	apk update && apk upgrade && apk add --no-cache nginx

#	define necessary envs
ARG DOMAIN_NAME_ARG
ENV DOMAIN_NAME=$DOMAIN_NAME_ARG USER=www-data TLS_VER=1.2

#	copy scripts
COPY conf/setup_hosts.sh /root/
RUN chmod +x /root/setup_hosts.sh

#	create non root user
RUN adduser --ingroup www-data -DH www-data

#	create necessary directories && files
RUN	mkdir -p /run/nginx/ /etc/nginx/ssl; touch /var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log

#	configure wordpress virtual host
RUN	--mount=type=secret,id=wp_cert \
	--mount=type=secret,id=wp_cert_key \
	/root/setup_hosts.sh "$(cat /run/secrets/wp_cert)" "$(cat /run/secrets/wp_cert_key)"

#	set ownership on necessary directories/fikes
RUN chown www-data:www-data /var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log
RUN chown -R www-data:www-data /run/nginx/ /etc/nginx/http.d/wordpress.conf /var/lib/nginx/
RUN chmod -R 700 /etc/nginx/http.d/wordpress.conf /var/lib/nginx/ \
	/var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log

#	switch to non root user
WORKDIR		/etc/nginx
USER		www-data
EXPOSE		443
ENTRYPOINT	[ "nginx", "-g", "daemon off;" ]