#!/usr/bin/env bash
set -e

echo "Starting Frappe HRMS init (Frappe v15)"

BENCH_DIR="/home/frappe/frappe-bench"
SITES_DIR="$BENCH_DIR/sites"

# Required environment variables
: "${DB_HOST:?DB_HOST is required}"
: "${DB_PORT:?DB_PORT is required}"
: "${DB_ROOT_PASSWORD:?DB_ROOT_PASSWORD is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"
: "${REDIS_CACHE:?REDIS_CACHE is required}"
: "${REDIS_QUEUE:?REDIS_QUEUE is required}"
: "${REDIS_SOCKETIO:?REDIS_SOCKETIO is required}"

SITE_NAME="${SITE_NAME:-site1.local}"

cd "$BENCH_DIR"

# Write common_site_config.json
echo "Writing common_site_config.json"

cat > "$SITES_DIR/common_site_config.json" <<EOF
{
  "db_host": "${DB_HOST}",
  "db_port": ${DB_PORT},
  "redis_cache": "redis://${REDIS_CACHE}",
  "redis_queue": "redis://${REDIS_QUEUE}",
  "redis_socketio": "redis://${REDIS_SOCKETIO}",
  "socketio_port": 9000
}
EOF

# Create site if it does not exist
if [ ! -d "$SITES_DIR/$SITE_NAME" ]; then
  echo "Creating site: $SITE_NAME"

  bench new-site "$SITE_NAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --mariadb-root-password "$DB_ROOT_PASSWORD" \
    --db-host "$DB_HOST" \
    --db-port "$DB_PORT"
else
  echo "Site already exists: $SITE_NAME"
fi

# Install ERPNext if not installed
if ! bench --site "$SITE_NAME" list-apps | grep -q "^erpnext$"; then
  echo "Installing ERPNext"
  bench --site "$SITE_NAME" install-app erpnext
else
  echo "ERPNext already installed"
fi

# Install HRMS if not installed
if ! bench --site "$SITE_NAME" list-apps | grep -q "^hrms$"; then
  echo "Installing HRMS"
  bench --site "$SITE_NAME" install-app hrms
else
  echo "HRMS already installed"
fi

# Run migrate (safe to run multiple times)
echo "Running migrate"
bench --site "$SITE_NAME" migrate

# Clear cache
echo "Clearing cache"
bench --site "$SITE_NAME" clear-cache

echo "Frappe HRMS init completed"
