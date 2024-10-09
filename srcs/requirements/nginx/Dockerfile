FROM	alpine:latest
RUN	apk update && apk upgrade && apk add nginx

#	create non root user
RUN adduser -DH nginx_user nginx
USER nginx_user

CMD [ "nginx", "-g", "deamon off;" ]
