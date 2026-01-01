#!/bin/bash
set -e

# Create database and user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "global_DB" WITH ENCODING 'UTF8' TEMPLATE template0;
    CREATE ROLE "global-signal_-charter" WITH LOGIN PASSWORD 'Mv@10111';
    GRANT ALL PRIVILEGES ON DATABASE "global_DB" TO "global-signal_-charter";
    \c global_DB
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
    ALTER SCHEMA public OWNER TO "global-signal_-charter";
    GRANT ALL ON ALL TABLES IN SCHEMA public TO "global-signal_-charter";
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "global-signal_-charter";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "global-signal_-charter";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "global-signal_-charter";
EOSQL

# Connect to global_DB and run schema
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "global_DB" < /docker-entrypoint-initdb.d/init.sql

