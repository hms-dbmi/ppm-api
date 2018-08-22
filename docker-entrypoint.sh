#!/bin/sh
set -e

# Retrieve database details
export KONG_DATABASE=postgres
export KONG_PG_HOST=$(aws ssm get-parameters --names $PS_PATH.db_host --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')
export KONG_PG_USER=$(aws ssm get-parameters --names $PS_PATH.db_user --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')
export KONG_PG_PASSWORD=$(aws ssm get-parameters --names $PS_PATH.db_password --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')
export KONG_PG_DATABASE=$(aws ssm get-parameters --names $PS_PATH.db_database --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')

# Configure other parts of the API
export KONG_PROXY_LISTEN=$(aws ssm get-parameters --names $PS_PATH.proxy_listen --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')
export KONG_ADMIN_LISTEN=$(aws ssm get-parameters --names $PS_PATH.admin_listen --with-decryption --region us-east-1 | jq -r '.Parameters[].Value')

# Setup logging
export KONG_PROXY_ACCESS_LOG=/dev/stdout
export KONG_ADMIN_ACCESS_LOG=/dev/stdout
export KONG_PROXY_ERROR_LOG=/dev/stderr
export KONG_ADMIN_ERROR_LOG=/dev/stderr

# Waiting for postgres
until psql --host=$KONG_PG_HOST --username=$KONG_PG_USER $KONG_PG_DATABASE -w &>/dev/null
do
  echo "Waiting for PostgreSQL..."
  sleep 3
done

echo "Postgres is ready, running the migrations..."

kong migrations up

echo "Kong migrations are ready, running Kong..."

export KONG_NGINX_DAEMON=off

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}
  mkdir -p $PREFIX

  if [[ "$2" == "docker-start" ]]; then
    kong prepare -p $PREFIX

    exec /usr/local/openresty/nginx/sbin/nginx \
      -p $PREFIX \
      -c nginx.conf
  fi
fi

exec "$@"