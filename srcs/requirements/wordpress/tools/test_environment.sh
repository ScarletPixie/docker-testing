#!/bin/sh

set -e

WP_ADMIN_NAME="$(cat /run/secrets/wp_admin_name)"
WP_ADMIN_EMAIL="$(cat /run/secrets/wp_admin_email)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_NAME="$(cat /run/secrets/wp_user_name)"
WP_USER_EMAIL="$(cat /run/secrets/wp_user_email)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"
DB_PASSWORD="$(cat /run/secrets/db_user_password)"

test -n "$WP_TITLE" || (echo "WP_TITLE is not set" && false)
test -n "$DOMAIN_NAME" || (echo "DOMAIN_NAME is not set" && false)
test -n "$WP_USER_NAME" || (echo "WP_USER_NAME is not set" && false)
test -n "$WP_USER_EMAIL" || (echo "WP_USER_EMAIL is not set" && false)
test -n "$WP_USER_PASSWORD" || (echo "WP_USER_PASSWORD is not set" && false)
test -n "$WP_ADMIN_NAME" || (echo "WP_ADMIN_NAME is not set" && false)
test -n "$WP_ADMIN_EMAIL" || (echo "WP_ADMIN_EMAIL is not set" && false)
test -n "$WP_ADMIN_PASSWORD" || (echo "WP_ADMIN_PASSWORD is not set " && false)
test -n "$DB_USER" || (echo "DB_USER is not set" && false)
test -n "$DB_PASSWORD" || (echo "DB_PASSWORD is not set" && false)

trap "rm -rf /root/$0" EXIT