# Paperless-ngx on Railway
# Uses the official paperless-ngx image with environment-based configuration
FROM paperlessngx/paperless-ngx:3.0.4

# The base image already has ENTRYPOINT ["/init"] and runs s6-overlay services
# No need to override ENTRYPOINT or CMD

# Paperless-ngx listens on port 8000
EXPOSE 8000
