FROM	alpine:3.19.4

COPY ./tools/test_environment.sh /etc/init.d/

RUN		--mount=type=secret,id=redis_password\
		test -n $(cat /run/secrets/redis_password | tr -d '[:space:]') || (echo "invalid redis_password file!" && false)

RUN		apk update && apk upgrade && apk add --no-cache redis

RUN		--mount=type=secret,id=redis_password \
		chmod +x /etc/init.d/* && \
		/etc/init.d/test_environment.sh $(cat /run/secrets/redis_password | tr -d '[:space:]') && \
		sed -i '/bind 127.0.0.1 -::1/c\bind 0.0.0.0' /etc/redis.conf && \
		sed -i '/protected mode yes/c\protected mode no' /etc/redis.conf && \
		sed -i "/# requirepass/c\requirepass $(cat /run/secrets/redis_password)" /etc/redis.conf

RUN		adduser --ingroup www-data -DH www-data && \
		mkdir -p /var/log/redis/ /var/run/redis &&  \
		touch /var/log/redis/redis.log && \
		chown -R www-data:www-data /var/log/redis/ /var/run/redis

EXPOSE		6379
USER		www-data
ENTRYPOINT	[ "redis-server", "/etc/redis.conf" ]