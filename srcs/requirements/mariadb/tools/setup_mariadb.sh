#!/bin/sh

wordpress_ip_address=$(getent hosts inception_wordpress | awk '{ print $1 }')

if [ -z $wordpress_ip_address ]; then
	sed -i "/bind-address=.\*/c\bind-address=${wordpress_ip_address}" /etc/my.cnf.d/mariadb-server.cnf
else
	echo "couldn't resolve wordpress container ip, using default 0.0.0.0"
	sed -i '/bind-address=.\*/c\bind-address=0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf
fi
sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf


mariadb-install-db --user="$MYSQL_USER" --datadir="${MYSQL_DATADIR}"

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