#!/usr/bin/env bash

# Entrypoint for conditional Tailscale serve/funnel
# Usage: ./tailscale-daemon.sh

set -e

# Default to private if not set
TS_PRIVACY="${TS_PRIVACY:-private}"

if [ "$TS_PRIVACY" = "private" ]; then
  echo "[tailscale-daemon] Running in PRIVATE mode: tailscale serve 127.0.0.1:$DDEV_ROUTER_HTTP_PORT"
  tailscale serve 127.0.0.1:$DDEV_ROUTER_HTTP_PORT
else
  echo "[tailscale-daemon] Running in PUBLIC mode: tailscale funnel 127.0.0.1:$DDEV_ROUTER_HTTP_PORT"
  tailscale funnel 127.0.0.1:$DDEV_ROUTER_HTTP_PORT
fi
