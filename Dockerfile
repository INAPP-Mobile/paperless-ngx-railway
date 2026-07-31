# Paperless-ngx on Railway
# Uses the official paperless-ngx image with environment-based configuration
FROM ghcr.io/paperless-ngx/paperless-ngx:3.0.4

# Install wget for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/*

# Paperless-ngx listens on port 8000
EXPOSE 8000

# Healthcheck — Paperless exposes HTTP on port 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD wget -qO- http://localhost:${PORT:-8000}/health || exit 1

# Use the original entrypoint; CMD runs the app via s6
# Environment variables (DATABASE_URL, REDIS_URL, PAPERLESS_*) are passed through
