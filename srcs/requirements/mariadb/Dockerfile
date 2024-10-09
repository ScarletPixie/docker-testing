FROM	alpine:latest
COPY	./conf /

#	install mariadb
RUN	apk update && apk upgrade && apk add mariadb && apk add mariadb-client

#   open connections to all interfaces and allow connections outside localhost
RUN	sed -i '/bind-address=.*/c\bind-address=0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf; \
		sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf;
RUN	mkdir -p /run/mysqld /var/lib/mysql

#	create non root user
RUN adduser -DH mariadb

#	create necessary directories and set ownership
RUN	chown -R mariadb:mariadb /run/mysqld /var/lib/mysql

USER mariadb
RUN	mysql_install_db --user=mariadb --datadir=/var/lib/mysql


EXPOSE  3306
CMD     ["mysqld", "--user=mariadb", "--datadir=/var/lib/mysql"]