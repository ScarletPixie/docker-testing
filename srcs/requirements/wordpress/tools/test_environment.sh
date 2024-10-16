#!/bin/sh

set -e

MYSQL_PASSWORD=$(cat /tmp/mysql_password)
WP_ADMIN_PASSWORD=$(cat /tmp/wp_admin_password)
WP_PASSWORD=$(cat /tmp/wp_password)

test -n "$WP_USER" || (echo "WP_USER is not set" && false)
test -n "$WP_EMAIL" || (echo "WP_EMAIL is not set" && false)
test -n "$WP_PASSWORD" || (echo "WP_PASSWORD is not set" && false)
test -n "$DOMAIN_NAME" || (echo "DOMAIN_NAME is not set" && false)
test -n "$MYSQL_USER" || (echo "MYSQL_USER is not set" && false)
test -n "$MYSQL_PASSWORD" || (echo "MYSQL_PASSWORD is not set" && false)
test -n "$WP_TITLE" || (echo "WP_TITLE is not set" && false)
test -n "$WP_ADMIN" || (echo "WP_ADMIN is not set" && false)
test -n "$WP_ADMIN_EMAIL" || (echo "WP_ADMIN_EMAIL is not set" && false)
test -n "$WP_ADMIN_PASSWORD" || (echo "WP_ADMIN_PASSWORD is not set " && false)

trap "rm -rf /root/$0" EXIT