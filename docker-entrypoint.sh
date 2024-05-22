#!/bin/bash
set -eou pipefail

# usage: file_env VAR [DEFAULT]
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [[ -n "${!var:-}" && -n "${!fileVar:-}" ]]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [[ -n "${!var:-}" ]]; then
    val="${!var}"
  elif [[ -n "${!fileVar:-}" ]]; then
    val="$(< "${!fileVar}")"
  fi

  if [[ -n "$val" ]]; then
    export "$var"="$val"
  fi

  unset "$fileVar"
}

##############################
# Set admin user credentials #
##############################

file_env 'KEYCLOAK_ADMIN'
file_env 'KEYCLOAK_ADMIN_PASSWORD'

################################################
# Set database config from Heroku DATABASE_URL #
################################################
if [[ -n "${DATABASE_URL:-}" ]]; then
  echo "Found database configuration in DATABASE_URL=$DATABASE_URL"

  regex='^postgres://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+)$'
  if [[ $DATABASE_URL =~ $regex ]]; then
    DB_USER=${BASH_REMATCH[1]}
    DB_PASSWORD=${BASH_REMATCH[2]}
    DB_ADDR=${BASH_REMATCH[3]}
    DB_PORT=${BASH_REMATCH[4]}
    DB_DATABASE=${BASH_REMATCH[5]}

    echo "DB_ADDR=$DB_ADDR, DB_PORT=$DB_PORT, DB_DATABASE=$DB_DATABASE, DB_USER=$DB_USER, DB_PASSWORD=$DB_PASSWORD"

    export KC_DB="postgres"
    export KC_DB_URL="jdbc:postgresql://${DB_ADDR}:${DB_PORT}/${DB_DATABASE}"
    export KC_DB_USERNAME="$DB_USER"
    export KC_DB_PASSWORD="$DB_PASSWORD"
  fi
fi

##################
# Start Keycloak #
##################

CONFIG_ARGS=""
SERVER_OPTS="--http-port=$PORT --proxy=edge --cluster=local"

if [[ -n "${KC_DB_URL:-}" ]]; then
  SERVER_OPTS="$SERVER_OPTS --db=${KC_DB} --db-url=${KC_DB_URL} --db-username=${KC_DB_USERNAME} --db-password=${KC_DB_PASSWORD}"
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    config)
      exec /opt/keycloak/bin/kc.sh config "$@" &
      wait $!
      ;;
    start)
      exec /opt/keycloak/bin/kc.sh start $SERVER_OPTS
      ;;
    *)
      CONFIG_ARGS="$CONFIG_ARGS $1"
      ;;
  esac
  shift
done

exec /opt/keycloak/bin/kc.sh start $SERVER_OPTS $CONFIG_ARGS
