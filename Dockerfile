# Paperless-ngx on Railway
# Uses the official paperless-ngx image with environment-based configuration
FROM paperlessngx/paperless-ngx:3.0.4

# The base image already has:
#   ENTRYPOINT ["/init"]   (s6-overlay init)
#   HEALTHCHECK ...        (curl on localhost:8000)
# We don't override either — just pass through environment variables.

# Paperless-ngx listens on port 8000
EXPOSE 8000
