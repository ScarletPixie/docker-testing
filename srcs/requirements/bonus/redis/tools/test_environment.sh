#!/bin/sh

set -e

REDIS_PASSWORD="$1"

if [ -z "$REDIS_PASSWORD" ]; then
	echo "invalid redis password file" && exit 1;
fi