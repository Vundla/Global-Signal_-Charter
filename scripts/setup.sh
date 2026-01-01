#!/bin/bash

# UbuntuNet Global - Quick Setup Script
# Installs dependencies and initializes the database

set -e

echo "🐆🦁🐇 UbuntuNet Global Setup"
echo "================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}❌ Cannot detect OS${NC}"
    exit 1
fi

echo -e "\n${YELLOW}📦 Installing Dependencies...${NC}"

# Install PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "Installing PostgreSQL..."
    case $OS in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y postgresql postgresql-contrib postgis
            ;;
        fedora|rhel|centos)
            sudo dnf install -y postgresql-server postgis
            sudo postgresql-setup --initdb
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
fi

# Start PostgreSQL
echo "Starting PostgreSQL service..."
case $OS in
    ubuntu|debian)
        sudo service postgresql start
        ;;
    fedora|rhel|centos)
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        ;;
esac

# Check PostgreSQL status
if sudo service postgresql status &> /dev/null || sudo systemctl is-active postgresql &> /dev/null; then
    echo -e "${GREEN}✅ PostgreSQL is running${NC}"
else
    echo -e "${RED}❌ PostgreSQL failed to start${NC}"
    exit 1
fi

# Install Elixir if not present
if ! command -v elixir &> /dev/null; then
    echo "Installing Elixir..."
    case $OS in
        ubuntu|debian)
            sudo apt-get install -y elixir
            ;;
        fedora|rhel|centos)
            sudo dnf install -y elixir
            ;;
    esac
fi

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    case $OS in
        ubuntu|debian)
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        fedora|rhel|centos)
            sudo dnf install -y nodejs
            ;;
    esac
fi

echo -e "\n${YELLOW}🗄️  Initializing Database...${NC}"

# Create database and user
sudo -u postgres psql <<EOF
-- Create database
CREATE DATABASE "global_DB" WITH ENCODING 'UTF8' TEMPLATE template0;

-- Create user
CREATE ROLE "global-signal_-charter" WITH
    LOGIN
    NOSUPERUSER
    INHERIT
    CREATEDB
    NOCREATEROLE
    NOREPLICATION
    PASSWORD 'Mv@10111';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE "global_DB" TO "global-signal_-charter";

\c global_DB

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Set schema ownership
ALTER SCHEMA public OWNER TO "global-signal_-charter";

-- Grant all on schema
GRANT ALL ON ALL TABLES IN SCHEMA public TO "global-signal_-charter";
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "global-signal_-charter";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "global-signal_-charter";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES TO "global-signal_-charter";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO "global-signal_-charter";

EOF

# Run the full initialization script
echo "Running full database initialization..."
cd "$(dirname "$0")/.."
sudo -u postgres psql -d global_DB -U postgres < backend/priv/repo/init.sql 2>&1 | grep -i "create\|insert\|error" || true

# Verify connection
echo -e "\n${YELLOW}🔍 Verifying Database Setup...${NC}"
PGPASSWORD=Mv@10111 psql -U global-signal_-charter -d global_DB -c "\dt" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database 'global_DB' initialized successfully${NC}"
    echo -e "${GREEN}✅ User 'global-signal_-charter' created${NC}"
    echo -e "${GREEN}✅ Schema 'public' owned by global-signal_-charter${NC}"
else
    echo -e "${RED}❌ Database verification failed${NC}"
    exit 1
fi

# List tables
echo -e "\n${YELLOW}📋 Created Tables:${NC}"
PGPASSWORD=Mv@10111 psql -U global-signal_-charter -d global_DB -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;" -t

echo -e "\n${YELLOW}🧪 Installing Backend Dependencies...${NC}"
cd backend
if [ -f "mix.exs" ]; then
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
fi

echo -e "\n${YELLOW}🎨 Installing Frontend Dependencies...${NC}"
cd ../frontend
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
fi

echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ UbuntuNet Global Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}📊 Next Steps:${NC}"
echo "1. Start backend:  cd backend && mix phx.server"
echo "2. Start frontend: cd frontend && npm run dev"
echo "3. Check scores:   ./scripts/scoring_tracker.exs"
echo ""
echo "Database: global_DB"
echo "User:     global-signal_-charter"
echo "Password: Mv@10111"
echo ""
echo -e "${YELLOW}🐆🦁🐇 Ubuntu: I am because we are${NC}"
