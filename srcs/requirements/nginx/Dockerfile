FROM	alpine:3.19.4

#	install nginx
RUN	apk update && apk upgrade && apk add --no-cache nginx

#	define necessary envs
ARG DOMAIN_NAME_ARG
ENV DOMAIN_NAME=$DOMAIN_NAME_ARG

#	copy scripts
COPY tools/create_wordpress_host.sh /root/
RUN chmod +x /root/create_wordpress_host.sh

#	create non root user
RUN adduser --ingroup www-data -DH www-data

#	create necessary directories && files
RUN	mkdir -p /run/nginx/ /etc/nginx/ssl; touch /var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log

#	configure wordpress virtual host
RUN	--mount=type=secret,id=wp_cert \
	--mount=type=secret,id=wp_cert_key \
	/root/create_wordpress_host.sh "$(cat /run/secrets/wp_cert)" "$(cat /run/secrets/wp_cert_key)"

#	set ownership on necessary directories/fikes
RUN chown www-data:www-data /var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log
RUN chown -R www-data:www-data /run/nginx/ /etc/nginx/http.d/wordpress.conf /var/lib/nginx/

RUN chmod -R 700 /etc/nginx/http.d/wordpress.conf /var/lib/nginx/ \
	/var/lib/nginx/logs/error.log /var/lib/nginx/logs/access.log

#	remove tlsv1 from default setting in nginx and remove default nginx page
RUN sed -i '/ssl_protocols.*/c\ssl_protocols TLSv1.2;' /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/http.d/default.conf

#	delete user line
RUN sed -i '/user nginx/d' /etc/nginx/nginx.conf

#	switch to non root user
USER		www-data
EXPOSE		443
ENTRYPOINT	[ "nginx", "-g", "daemon off;" ]
