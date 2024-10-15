#!/bin/sh

MYSQL_PASSWORD="$1"
MYSQL_ROOT_PASSWORD="$2"

#	make mariadb accept external connections
sed -i '/bind-address=.\*/c\bind-address=0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf
sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf

#	init datadir with non root user
mariadb-install-db --user="$MYSQL_USER" --datadir="${MYSQL_DATADIR}"

#	init server to apply initial setup
mariadbd --user=root --datadir="${MYSQL_DATADIR}" &
status=1
while [ $status -eq 1 ];
do
	sleep 1
	mariadb-admin status
	status=$?
done

#	set root and database password
mariadb <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'inception_wordpress.inception_mariadb_to_wordpress' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON wordpress.* to '$MYSQL_USER'@'inception_wordpress.inception_mariadb_to_wordpress';
FLUSH PRIVILEGES;
EXIT;
EOF

#	shutdown server to be initialized as PID 1 later
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait

#	remove this setup script
trap "rm -rf /root/$0" EXIT