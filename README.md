[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/serene-light)

# Deploy and Host Paperless-ngx on Railway

Paperless-ngx is the fork of the original Paperless application — a document management system that transforms your physical documents into a searchable digital archive. It features OCR, automatic tagging, document classification, and a modern web interface.

## About Hosting Paperless-ngx on Railway

This template deploys Paperless-ngx with PostgreSQL (database), Valkey/Redis (task broker), and persistent storage volumes on Railway. The Paperless service runs the web server and background task consumer in a single process.

### Features

- **OCR & Text Extraction** — Automatic text recognition from scanned documents
- **Document Tagging** — Automatic and manual tagging with AI-powered suggestions
- **Search** — Full-text search across all documents
- **Document Types** — Support for PDF, Office docs, images, emails, and more
- **Consumption Directory** — Drop files to automatically ingest and process
- **API** — RESTful API for programmatic access
- **Multi-user** — Role-based access control with Django auth
- **Dark Mode** — Built-in dark theme support

## Why Deploy Paperless-ngx on Railway

- **One-click deployment** — PostgreSQL and Redis are set up automatically as companion services
- **Persistent storage** — Database and document data persist across deploys via Railway volumes
- **Auto-scaling** — Scale vertically as your document archive grows
- **Custom domains** — Add your own domain with automatic TLS certificates
- **Managed infrastructure** — No need to manage your own database or Redis instances

## Quick Start

1. Click the Deploy to Railway button above
2. Wait for provisioning (~2-3 minutes for image pull and DB init)
3. Open the application at your deployed Railway URL
4. The default admin credentials are printed in the deployment logs

## Prerequisites

- A Railway account (free tier available)
- No local setup required — everything runs on Railway

## Architecture

```
                    ┌─────────────────────────────────────────────────────┐
                    │           Railway Project                           │
                    │                                                     │
  ┌─────────────┐   │  ┌──────────────────────┐                         │
  │  PostgreSQL │   │  │   Paperless-ngx      │                         │
  │  (companion)│   │  │   (main service)     │                         │
  │  port 5432  │   │  │   port 8000          │                         │
  └─────────────┘   │  └──────────┬───────────┘                         │
                    │             │                                      │
  ┌─────────────┐   │             │                                      │
  │  Valkey     │   │             │                                      │
  │  (Redis)    │   │             │                                      │
  │  (companion)│   │             │                                      │
  │  port 6379  │   │             │                                      │
  └─────────────┘   │             │                                      │
                    │             │                                      │
                    │  ┌──────────▼───────────┐                          │
                    │  │  Persistent Volumes  │                          │
                    │  │  (postgres + redis   │                          │
                    │  │   + paperless data)  │                          │
                    │  └──────────────────────┘                          │
                    └─────────────────────────────────────────────────────┘
```

## Common Use Cases

- Personal document archiving and search
- Small office paperless workflow
- Receipt and invoice management
- Academic paper organization
- Legal document management

## Dependencies for Paperless-ngx on Railway

This template requires the following services:

### Deployment Dependencies

- **PostgreSQL** — Required. Automatically deployed as a companion service.
- **Valkey/Redis** — Required. Automatically deployed as a companion service for Celery task broker.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8000` | Port for the Paperless-ngx web server |
| `PAPERLESS_SECRET_KEY` | (auto) | Secret key for session tokens and signing. Auto-generated if not set. |
| `PAPERLESS_REDIS` | (auto) | Redis connection string. Auto-detected from the Redis companion service. |
| `PAPERLESS_DBENGINE` | `postgresql` | Database engine (postgresql) |
| `PAPERLESS_DBHOST` | (auto) | PostgreSQL host. Auto-detected from the Postgres companion service. |
| `PAPERLESS_DBPORT` | `5432` | PostgreSQL port |
| `PAPERLESS_DBNAME` | `paperless` | Database name. Must match `POSTGRES_DB` on the Postgres service. |
| `PAPERLESS_DBUSER` | (auto) | PostgreSQL username. Auto-detected from the Postgres companion service. |
| `PAPERLESS_DBPASS` | (auto) | PostgreSQL password. Auto-detected from the Postgres companion service. |
| `PAPERLESS_DBSSLMODE` | `prefer` | SSL mode for PostgreSQL connection |
| `PAPERLESS_URL` | (auto) | Public URL. Auto-detected from the Railway domain. |
| `PAPERLESS_TIME_ZONE` | `UTC` | Timezone for document processing |
| `PAPERLESS_OCR_LANGUAGE` | `eng` | Default OCR language |
| `PAPERLESS_OCR_LANGUAGES` | `eng` | Additional OCR languages (space-separated) |
| `PAPERLESS_CONSUMER_RECURSIVE` | `true` | Whether consumer recursively scans subdirectories |
| `PAPERLESS_CONSUMER_POLLING_INTERVAL` | `0` | Polling interval (0 = event-driven) |

### Postgres Service

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `paperless` | Database superuser |
| `POSTGRES_PASSWORD` | auto-generated | Database password (auto-generated secret) |
| `POSTGRES_DB` | `paperless` | Initial database name |
| `PGDATA` | `/var/lib/postgresql/data/pgdata` | Postgres data directory |

### Redis Service

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PASSWORD` | auto-generated | Redis password (auto-generated secret) |
| `REDIS_URL` | `redis://:${REDIS_PASSWORD}@${RAILWAY_PRIVATE_DOMAIN}:6379` | Redis/Valkey connection URL with password |

## Persistent Storage

Each service has a Railway volume attached for data persistence:

- **PostgreSQL** — `postgres-volume` mounted at `/var/lib/postgresql/data`
- **Redis** — `redis-volume` mounted at `/data`
- **Paperless-ngx** — `paperless-ngx-volume` mounted at `/usr/src/paperless/data` (consumption directory, OCR cache, and other state)

Note: Railway limits each service to one volume. The Paperless-ngx media directory (`/usr/src/paperless/media`) is not persisted on a separate volume — generated thumbnails and media files can be regenerated by the application.

The Paperless-ngx service exposes a health endpoint at `/health`. Railway monitors this endpoint to ensure the service is running. The endpoint returns a 302 redirect to the login page when unauthenticated, which Railway accepts as a healthy response.

## Project Structure

```
├── Dockerfile              # Paperless-ngx service build (uses official image)
├── docker-entrypoint.sh    # Railway-aware entrypoint (auto-configures DB/Redis/URL)
├── railway.json            # Railway build/deploy config
├── postgres/
│   ├── Dockerfile          # Postgres service build
│   ├── railway.json        # Postgres deploy config with volume mount
│   └── template-vars.json  # Postgres template variables
├── redis/
│   ├── Dockerfile          # Valkey/Redis service build
│   ├── railway.json        # Redis deploy config with volume mount
│   └── template-vars.json  # Redis template variables
├── template-vars.json      # Template variables for Railway marketplace
└── template-editor-raw.json # Raw template editor variable values
```

## Security Notes

- Change the default Postgres password (`paperless`) after first deployment
- Set a strong `PAPERLESS_SECRET_KEY` for session token signing (auto-generated on first deploy if left as default)
- Configure a custom domain with HTTPS for production use
- The default admin credentials are printed in the Railway deployment logs after first startup

## Learn More

- [Paperless-ngx Documentation](https://docs.paperless-ngx.com)
- [Paperless-ngx GitHub](https://github.com/paperless-ngx/paperless-ngx)
- [Railway Documentation](https://docs.railway.app)
