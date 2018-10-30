#!/usr/bin/env bash

CONF_DIR="/usr/local/openresty/nginx/conf"

if [ "$NAMESERVER" == "" ]; then
  export NAMESERVER=$(awk '/^nameserver/{print $2}' /etc/resolv.conf)
fi

[ -z "$SESSION_SECRET" ] && echo "SESSION_SECRET must be set" && exit 1

envsubst '$NAMESERVER $SESSION_SECRET' < "$CONF_DIR/nginx.conf.template" > "$CONF_DIR/nginx.conf" 

exec "$@"
