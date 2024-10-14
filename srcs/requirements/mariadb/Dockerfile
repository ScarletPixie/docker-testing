FROM	alpine:3.19.4

COPY ./tools/setup_mariadb.sh /root/
COPY ./tools/test_environment.sh /root/
RUN chmod +x /root/setup_mariadb.sh
RUN chmod +x /root/test_environment.sh

ARG	MYSQL_USER_ARG
ARG MYSQL_PASSWORD_ARG
ARG	MYSQL_DATADIR_ARG
ARG MYSQL_ROOT_PASSWORD_ARG

ENV	MYSQL_USER=$MYSQL_USER_ARG
ENV	MYSQL_DATADIR=$MYSQL_DATADIR_ARG
ENV	MYSQL_PASSWORD=$MYSQL_PASSWORD_ARG
ENV	MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD_ARG

#	test if necessary arguments are set
RUN	/root/test_environment.sh

#	install mariadb
RUN	apk update && apk upgrade && apk add --no-cache mariadb && apk add --no-cache mariadb-client

#	create necessary directories
#RUN	mkdir -p ${MYSQL_DATADIR}
RUN	mkdir -p /run/mysqld
RUN	mkdir -p /var/log/mysql

#	create non root user
RUN	adduser -DH ${MYSQL_USER}

#	setup mariadb
RUN	/root/setup_mariadb.sh

#	set permissions
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATADIR}
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} /run/mysqld/
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} /var/log/mysql/
RUN	chown ${MYSQL_USER}:${MYSQL_USER} /etc/my.cnf.d/mariadb-server.cnf
RUN	chown ${MYSQL_USER}:${MYSQL_USER} /etc/my.cnf

#	override sensitive data
ENV	MYSQL_PASSWORD='https://www.youtube.com/watch?v=dQw4w9WgXcQ'
ENV	MYSQL_ROOT_PASSWORD='https://www.youtube.com/watch?v=dQw4w9WgXcQ'

EXPOSE	3306
USER	$MYSQL_USER

CMD	mariadbd-safe --user="$MYSQL_USER" --datadir="$MYSQL_DATADIR"