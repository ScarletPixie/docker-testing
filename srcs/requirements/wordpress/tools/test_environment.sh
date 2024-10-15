#!/bin/sh

set -e


test -n "$MYSQL_USER" || (echo "MYSQL_USER is not set" && false)
test -n "$MYSQL_PASSWORD" || (echo "MYSQL_PASSWORD is not set" && false)
trap "rm -rf /root/$0" EXIT