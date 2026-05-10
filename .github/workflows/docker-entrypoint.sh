#!/bin/bash
set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL database..."
    chown -R postgres:postgres "$PGDATA"
    gosu postgres initdb -D "$PGDATA" --auth-host=scram-sha-256 --auth-local=scram-sha-256
fi

# راه‌اندازی سرور PostgreSQL
exec gosu postgres postgres -D "$PGDATA" -c listen_addresses='*'
