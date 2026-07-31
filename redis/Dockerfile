FROM valkey/valkey:8-alpine

# Valkey is a drop-in Redis replacement — Paperless-ngx uses it as the
# Celery broker and optional cache backend.
# The valkey image starts automatically on port 6379.

EXPOSE 6379

# Default command — run valkey server
CMD ["valkey-server", "--appendonly", "yes"]
