FROM	alpine:3.19.4

#	copy necessary setup files
COPY ./tools/setup_mariadb.sh /root/
COPY ./tools/test_environment.sh /root/
RUN chmod +x /root/setup_mariadb.sh
RUN chmod +x /root/test_environment.sh

#	define args, passed by compose
ARG	MYSQL_USER_ARG
ARG MYSQL_PASSWORD_ARG
ARG	MYSQL_DATADIR_ARG
ARG MYSQL_ROOT_PASSWORD_ARG

#	store arg values into container
ENV	MYSQL_USER=$MYSQL_USER_ARG
ENV	MYSQL_DATADIR=$MYSQL_DATADIR_ARG

#	test if necessary arguments are set
RUN	/root/test_environment.sh "${MYSQL_PASSWORD_ARG}" "${MYSQL_ROOT_PASSWORD_ARG}"

#	install mariadb
RUN	apk update && apk upgrade && apk add --no-cache mariadb && apk add --no-cache mariadb-client

#	create necessary directories
RUN	mkdir -p /run/mysqld
RUN	mkdir -p /var/log/mysql

#	create non root user
RUN	adduser -DH ${MYSQL_USER}

#	setup mariadb
RUN	/root/setup_mariadb.sh "${MYSQL_PASSWORD_ARG}" "${MYSQL_ROOT_PASSWORD_ARG}"

#	set permissions
#	ownership for necessary directories
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATADIR}
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} /run/mysqld/
RUN	chown -R ${MYSQL_USER}:${MYSQL_USER} /var/log/mysql/

#	mariadb server's configuration files
RUN	chown ${MYSQL_USER}:${MYSQL_USER} /etc/my.cnf.d/mariadb-server.cnf
RUN	chown ${MYSQL_USER}:${MYSQL_USER} /etc/my.cnf

#	expose port 3306 to other container on same network
EXPOSE	3306

#	switch to non root user
USER	$MYSQL_USER

#	start mariadb server
CMD	mariadbd-safe --user="$MYSQL_USER" --datadir="$MYSQL_DATADIR"