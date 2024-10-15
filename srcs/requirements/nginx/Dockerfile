FROM	alpine:3.19.4
RUN	apk update && apk upgrade && apk add nginx && apk add openssl

ARG DOMAIN_NAME
ENV DOMAIN_NAME=$DOMAIN_NAME

COPY tools/create_wordpress_host.sh /root/
RUN chmod +x /root/create_wordpress_host.sh

#	create non root user
RUN adduser --ingroup www-data -DH www-data

#	configure wordpress virtual host
RUN /root/create_wordpress_host.sh

#	set permissions for non root user
RUN	mkdir -p /run/nginx/
RUN touch /var/lib/nginx/logs/error.log; touch /var/lib/nginx/logs/access.log
RUN chown www-data:www-data /var/lib/nginx/logs/error.log; chown www-data:www-data /var/lib/nginx/logs/access.log
RUN chown -R www-data:www-data /run/nginx/
RUN chown -R www-data:www-data /etc/nginx/http.d/wordpress.conf
RUN chown -R www-data:www-data /var/lib/nginx/
RUN chown -R www-data:www-data /etc/nginx/ssl/wordpress.crt
RUN chown -R www-data:www-data /etc/nginx/ssl/wordpress.key
RUN chmod -R 700 /etc/nginx/http.d/wordpress.conf
RUN chmod -R 700 /var/lib/nginx/
RUN chmod 700 /etc/nginx/ssl/wordpress.crt; chmod 700 /etc/nginx/ssl/wordpress.key
RUN chmod 700 /var/lib/nginx/logs/error.log; chmod 700 /var/lib/nginx/logs/access.log
RUN chmod 700 /run/nginx/

#	remove tlsv1 from default setting in nginx
RUN sed -i '/ssl_protocols.*/c\ssl_protocols TLSv1.2 TLSv1.3;' /etc/nginx/nginx.conf


#	change nginx user
RUN sed -i '/user nginx/d' /etc/nginx/nginx.conf

EXPOSE 443
USER www-data
CMD [ "nginx", "-g", "daemon off;" ]
