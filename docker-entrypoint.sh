#!/bin/sh
# Paperless-ngx Railway entrypoint
# Auto-configures DB and Redis connection strings from Railway companion services

set -e

echo "=== Paperless-ngx Railway entrypoint ==="

# --- Redis auto-detection ---
# Railway provides REDIS_URL when a Redis/Valkey companion service is attached.
# Paperless-ngx expects PAPERLESS_REDIS=redis://host:port
if [ -z "$PAPERLESS_REDIS" ]; then
    if [ -n "$REDIS_URL" ]; then
        export PAPERLESS_REDIS="$REDIS_URL"
        echo "Auto-detected PAPERLESS_REDIS from REDIS_URL: $PAPERLESS_REDIS"
    elif [ -n "$REDIS_PRIVATE_DOMAIN" ]; then
        export PAPERLESS_REDIS="redis://${REDIS_PRIVATE_DOMAIN}:6379"
        echo "Auto-detected PAPERLESS_REDIS from REDIS_PRIVATE_DOMAIN: $PAPERLESS_REDIS"
    else
        echo "WARNING: PAPERLESS_REDIS not set and no Redis companion detected."
        echo "Paperless-ngx will use in-memory broker (background tasks disabled)."
        # Force Django to use local memory cache instead of Redis
        export PAPERLESS_REDIS=""
        export DJANGO_REDIS_URL=""
    fi
fi

# --- PostgreSQL auto-detection ---
# When a Postgres companion service is attached, Railway provides PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD.
if [ -n "$PGHOST" ] && [ -z "$PAPERLESS_DBHOST" ]; then
    export PAPERLESS_DBHOST="$PGHOST"
    export PAPERLESS_DBPORT="${PGPORT:-5432}"
    export PAPERLESS_DBNAME="${PGDATABASE:-paperless}"
    export PAPERLESS_DBUSER="$PGUSER"
    export PAPERLESS_DBPASS="$PGPASSWORD"
    echo "Auto-detected PostgreSQL connection from PG* env vars"
    echo "  DBHOST: $PAPERLESS_DBHOST"
    echo "  DBPORT: $PAPERLESS_DBPORT"
    echo "  DBNAME: $PAPERLESS_DBNAME"
fi

# --- URL auto-detection ---
if [ -z "$PAPERLESS_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    export PAPERLESS_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
    echo "Auto-detected PAPERLESS_URL: $PAPERLESS_URL"
fi

# --- Secret key generation ---
if [ -z "$PAPERLESS_SECRET_KEY" ] || [ "$PAPERLESS_SECRET_KEY" = "change-me-to-a-random-secret" ]; then
    export PAPERLESS_SECRET_KEY="$(python3 -c 'import secrets; print(secrets.token_urlsafe(64))')"
    echo "Generated random PAPERLESS_SECRET_KEY"
fi

# --- Run database migrations ---
echo "=== Running database migrations ==="
python3 /usr/src/paperless/src/manage.py migrate 2>&1 || {
    echo "ERROR: Database migrations failed!"
    exit 1
}
echo "=== Database migrations completed ==="

# --- Start Paperless-ngx ---
echo "=== Starting Paperless-ngx on port ${PORT:-8000} ==="
# Call the original Paperless-ngx entrypoint to start s6 and all services
# The original entrypoint handles s6-svscan startup, migrations, etc.
exec /usr/local/bin/paperless-original-entrypoint.sh paperless
