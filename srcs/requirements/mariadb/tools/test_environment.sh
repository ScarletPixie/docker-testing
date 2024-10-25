#!/bin/sh

set -e

MARIADB_PASSWORD="$1"
MARIADB_ROOT_PASSWORD="$2"

#	environment
test -n "$MARIADB_USER"	|| (echo "MARIADB_USER is not set" && false)
test -n "$MARIADB_DATADIR" || (echo "MARIADB_DATADIR is not set" && false)

#	passed by args
test -n "$MARIADB_PASSWORD" || (echo "MARIADB_PASSWORD is not set" && false)
test -n "$MARIADB_ROOT_PASSWORD" || (echo "MARIADB_ROOT_PASSWORD is not set" && false)

#	delete this file
trap "rm -rf /root/$0" EXIT