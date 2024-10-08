FROM    alpine:latest
COPY    ./conf /
RUN     apk update && apk upgrade && apk add mariadb && apk add mariadb-client

#create and init essential directories
RUN     mkdir -p /run/mysqld /var/lib/mysql && \
        chown -R mysql:mysql /run/mysqld /var/lib/mysql
RUN     mysql_install_db --user=mysql --datadir=/var/lib/mysql

#open connections to all interfaces and allow connections outside localhost
RUN     sed -i '/bind-address=.*/c\bind-address=0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf; \
        sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf;

EXPOSE  3306
CMD     ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql"]