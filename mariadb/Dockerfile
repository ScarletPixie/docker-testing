FROM    alpine:latest
COPY    ./conf /
RUN     apk update && apk upgrade && apk add mariadb && apk add mariadb-client

RUN     mkdir -p /run/mysqld /var/lib/mysql && \
        chown -R mysql:mysql /run/mysqld /var/lib/mysql
RUN     sed -i '/bind-address=.*/c\bind-address=0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf; \
        sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf; \
        sed -i '/\[mysqld\]/d' /etc/my.cnf.d/mariadb-server.cnf

EXPOSE  3306
RUN     mysql_install_db --user=mysql --datadir=/var/lib/mysql
CMD     ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql"]