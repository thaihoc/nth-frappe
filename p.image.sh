#!/usr/bin/env bash
set -e

APPS_JSON_BASE64=$(base64 apps.json | tr -d '\n')

podman build \
  --build-arg FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg FRAPPE_BRANCH=v16.0.0-rc.1 \
  --build-arg APPS_JSON_BASE64="$APPS_JSON_BASE64" \
  --tag frappe:16rc1 .
