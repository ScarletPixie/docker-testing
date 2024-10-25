FROM	alpine:3.19.4

#	copy necessary setup files
COPY ./conf/setup_mariadb.sh ./tools/test_environment.sh ./tools/entrypoint.sh /etc/init.d/
RUN chmod +x /etc/init.d/setup_mariadb.sh /etc/init.d/test_environment.sh /etc/init.d/entrypoint.sh

#	set environment
ARG MARIADB_USER_ARG=${MARIADB_USER}
ARG MARIADB_DATADIR_ARG=${MARIADB_DATADIR}
ENV MARIADB_USER=${MARIADB_USER_ARG} MARIADB_DATADIR=${MARIADB_DATADIR_ARG}

#	define build secrets and test if all variables are set
RUN --mount=type=secret,id=db_user_password \
	--mount=type=secret,id=db_root_password \
	/etc/init.d/test_environment.sh "$(cat /run/secrets/db_user_password)" "$(cat /run/secrets/db_root_password)"

#	install mariadb
RUN	apk update && apk upgrade && apk add --no-cache mariadb mariadb-client

#	create necessary directories
RUN	mkdir -p /run/mysqld /var/log/mysql

#	create non root user
RUN	adduser -DH ${MARIADB_USER}

#	setup mariadb
RUN --mount=type=secret,id=db_user_password \
	--mount=type=secret,id=db_root_password \
	/etc/init.d/setup_mariadb.sh "$(cat /run/secrets/db_user_password)" "$(cat /run/secrets/db_root_password)"

#	set ownership for non root user on necessary directories
RUN	chown -R ${MARIADB_USER}:${MARIADB_USER} ${MARIADB_DATADIR} /run/mysqld/ /var/log/mysql/ /etc/my.cnf.d/mariadb-server.cnf /etc/my.cnf

#	expose port 3306 to other container on same network
EXPOSE	3306

#	switch to non root user
USER	$MARIADB_USER
WORKDIR	$MARIADB_DATADIR

#	start mariadb server
ENTRYPOINT [ "/etc/init.d/entrypoint.sh"]