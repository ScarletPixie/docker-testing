#!/bin/sh

set -e

MYSQL_PASSWORD="$1"
MYSQL_ROOT_PASSWORD="$2"

#	environment
test -n "$MYSQL_USER" || (echo "MYSQL_USER is not set" && false)
test -n "$MYSQL_DATADIR" || (echo "MYSQL_DATADIR is not set" && false)

#	passed by args
test -n "$MYSQL_PASSWORD" || (echo "MYSQL_PASSWORD is not set" && false)
test -n "$MYSQL_ROOT_PASSWORD" || (echo "MYSQL_ROOT_PASSWORD is not set" && false)

#	delete this file
trap "rm -rf /root/$0" EXIT