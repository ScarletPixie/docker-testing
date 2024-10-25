#!/bin/sh
exec "mariadbd" "--user=$MARIADB_USER" "--datadir=$MARIADB_DATADIR"