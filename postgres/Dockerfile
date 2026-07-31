FROM postgres:18-alpine

# Postgres image entrypoint handles initdb + start automatically when
# POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB are set.
# Volume mount path: /var/lib/postgresql (parent of data dir)
# so lost+found stays outside PGDATA.
ENV PGDATA=/var/lib/postgresql/data/pgdata

EXPOSE 5432
