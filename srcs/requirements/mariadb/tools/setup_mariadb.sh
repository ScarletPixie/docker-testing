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
ALTER USER 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'inception_wordpress' identified by '$MYSQL_PASSWORD';
grant all privileges on wordpress.* to '$MYSQL_USER'@'inception_wordpress' with grant option;
flush privileges;
EXIT;
EOF
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait

trap "rm -rf /root/setup_mariadb.sh" EXIT