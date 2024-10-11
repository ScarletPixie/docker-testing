FROM	alpine:latest
RUN	apk update && apk upgrade && apk add nginx

#	create non root user
RUN adduser -DH nginx_user
RUN chown -R nginx_user:nginx_user /var/lib/nginx/


CMD [ "nginx", "-g", "daemon off;" ]
