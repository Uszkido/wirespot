#!/bin/sh
set -eu

template=/opt/wirespot/clients.conf.template
target=/etc/freeradius/3.0/clients.conf

sed \
  -e "s|__RADIUS_CLIENT_IP__|${RADIUS_CLIENT_IP}|g" \
  -e "s|__RADIUS_CLIENT_SECRET__|${RADIUS_CLIENT_SECRET}|g" \
  "$template" > "$target"

chown freerad:freerad "$target"
exec freeradius -f
