FROM	alpine:3.19.4
RUN	apk update && apk upgrade && apk add nginx && apk add openssl

COPY tools/create_wordpress_host.sh /root/
RUN chmod +x /root/create_wordpress_host.sh

RUN /root/create_wordpress_host.sh

#	create non root user
RUN adduser -DH nginx_user
RUN chown -R nginx_user:nginx_user /var/lib/nginx/

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]
