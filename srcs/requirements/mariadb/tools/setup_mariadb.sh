#!/bin/sh

MYSQL_USER_ENV=$MYSQL_USER
MYSQL_DATADIR_ENV=$MYSQL_DATADIR
MYSQL_PASSWORD_ENV=$MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD_ENV=$MYSQL_ROOT_PASSWORD

mariadbd --user=root --datadir="${MYSQL_DATADIR}" &
status=1
while [ $status -eq 1 ];
do
	sleep 1
	mariadb-admin status
	status=$?
done

mariadb <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON wordpress.* to '$MYSQL_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
EOF

#mariadb -u root -p"$MYSQL_ROOT_PASSWORD" wordpress < /root/create_wordpress_db.sql

mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait

rm -rf /root/create_wordpress_db.sql
trap "rm -rf /root/$0" EXIT