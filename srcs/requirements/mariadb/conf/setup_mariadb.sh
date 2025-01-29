#!/bin/sh

MARIADB_USER_PASSWORD="$1"
MARIADBL_ROOT_PASSWORD="$2"

#	make mariadb accept external connections
sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf

#	init datadir with non root user
mariadb-install-db --user="$MARIADB_USER" --datadir="${MARIADB_DATADIR}"

#	init server to apply initial setup
mariadbd --user=root --datadir="${MARIADB_DATADIR}" &
sleep 1
mariadb-admin status
status=$?
while [ $status -eq 1 ];
do
	sleep 1
	mariadb-admin status
	status=$?
done

#	set root and database password
mariadb <<EOF
--	basic setup --
CREATE DATABASE IF NOT EXISTS wordpress;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADBL_ROOT_PASSWORD';
ALTER USER 'paulhenr'@'localhost' IDENTIFIED BY '$MARIADB_USER_PASSWORD';
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'inception-wordpress.inception_mariadb_to_wordpress' IDENTIFIED BY '$MARIADB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON wordpress.* to '$MARIADB_USER'@'inception-wordpress.inception_mariadb_to_wordpress';

--	taken from: https://docs.bitnami.com/aws/infrastructure/mariadb/administration/secure-server-mariadb/
--	remove anonymous user
DELETE FROM mysql.user WHERE User='';

--	remove remote root user
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

--	remove test database
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
EXIT;
EOF

#	shutdown server to be initialized as PID 1 later
mariadb-admin -u root -p"${MARIADBL_ROOT_PASSWORD}" shutdown
wait

#	remove this setup script
trap "rm -rf /root/$0" EXIT