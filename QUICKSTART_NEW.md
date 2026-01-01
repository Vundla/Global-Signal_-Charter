# 🐆🦁🐇 UbuntuNet Global - Quick Start Guide
## Get Running in 5 Minutes

This guide will get your local development environment up and running with the complete UbuntuNet Global stack.

---

## 📋 Prerequisites

- **OS**: Ubuntu 24.04 LTS (or compatible Linux)
- **PostgreSQL**: 16+ with PostGIS extension
- **Elixir**: 1.17+ with Erlang/OTP 26.2+
- **Node.js**: 20+
- **Git**: Latest version

---

## 🚀 Automated Setup (Recommended)

Run the automated setup script:

```bash
cd /workspaces/Global-Signal_-Charter
./scripts/setup.sh
```

This will:
- Install PostgreSQL with PostGIS
- Create `global_DB` database
- Create `global-signal_-charter` user with password `Mv@10111`
- Install Elixir/Phoenix dependencies
- Install SvelteKit/frontend dependencies
- Run database migrations
- Seed initial data

**Expected output**:
```
✅ PostgreSQL is running
✅ Database 'global_DB' initialized successfully
✅ User 'global-signal_-charter' created
✅ Schema 'public' owned by global-signal_-charter
✅ Backend dependencies installed
✅ Frontend dependencies installed
```

---

## 🛠️ Manual Setup (If Automated Fails)

### Step 1: Install PostgreSQL

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib postgis

# Start service
sudo service postgresql start
```

### Step 2: Create Database

```bash
sudo -u postgres psql <<EOF
-- Create database
CREATE DATABASE "global_DB" WITH ENCODING 'UTF8' TEMPLATE template0;

-- Create user
CREATE ROLE "global-signal_-charter" WITH
    LOGIN PASSWORD 'Mv@10111';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE "global_DB" TO "global-signal_-charter";

\c global_DB

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Set schema ownership
ALTER SCHEMA public OWNER TO "global-signal_-charter";
EOF
```

### Step 3: Initialize Schema

```bash
cd /workspaces/Global-Signal_-Charter
sudo -u postgres psql -d global_DB -f backend/priv/repo/init.sql
```

Verify:
```bash
PGPASSWORD=Mv@10111 psql -U global-signal_-charter -d global_DB -c "\dt"
```

You should see tables like:
- countries
- towers
- communities
- tower_telemetry
- profit_ledger
- chaos_events
- dev_checklist
- audit_log

### Step 4: Install Elixir (if needed)

```bash
# Ubuntu/Debian
sudo apt-get install -y elixir

# Verify
elixir --version
# Expected: Elixir 1.17.x (compiled with Erlang/OTP 26.x)
```

### Step 5: Install Node.js (if needed)

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version  # Expected: v20.x
npm --version   # Expected: 10.x
```

### Step 6: Install Backend Dependencies

```bash
cd backend
mix local.hex --force
mix local.rebar --force
mix deps.get
```

### Step 7: Install Frontend Dependencies

```bash
cd ../frontend
npm install
```

---

## 🏃 Running the Application

### Terminal 1: Backend (Phoenix)

```bash
cd /workspaces/Global-Signal_-Charter/backend
mix phx.server
```

**Expected output**:
```
[info] Running GlobalSovereignWeb.Endpoint with Bandit 1.5.x at 127.0.0.1:4000 (http)
[info] Access GlobalSovereignWeb.Endpoint at http://localhost:4000
```

### Terminal 2: Frontend (SvelteKit)

```bash
cd /workspaces/Global-Signal_-Charter/frontend
npm run dev
```

**Expected output**:
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

### Access the Application

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:4000
- **Phoenix LiveDashboard**: http://localhost:4000/dev/dashboard

---

## 📊 Check Development Score

Track your implementation progress:

```bash
cd /workspaces/Global-Signal_-Charter
./scripts/scoring_tracker.exs
```

**Expected output**:
```
🐆🦁🐇 UbuntuNet Global - Scoring Tracker
================================================================

📊 MASTER SCORECARD

🔴 Foundation        : 0/100 ❌
🔴 Data Caching      : 0/100 ❌
🔴 Ai Security       : 0/100 ❌
🔴 Chaos             : 0/100 ❌
🔴 Community         : 0/100 ❌

────────────────────────────────────────
TOTAL: 0/500 ❌

⚠️  Need 450 more points for production (450 minimum)
```

---

## 🧪 Running Tests

### Backend Tests

```bash
cd backend

# Run all tests
mix test

# Run with coverage
mix coveralls

# Run security scan
mix sobelow --config

# Run linter
mix credo --strict
```

### Frontend Tests

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run linter
npm run lint

# Type check
npm run check
```

---

## 🗄️ Database Management

### Connect to Database

```bash
PGPASSWORD=Mv@10111 psql -U global-signal_-charter -d global_DB
```

### Common Queries

```sql
-- List all tables
\dt

-- Check countries
SELECT * FROM countries;

-- Check towers
SELECT id, name, status, country_id FROM towers;

-- View development checklist
SELECT phase, task, score, status FROM dev_checklist ORDER BY id;

-- Check total score
SELECT 
  phase, 
  ROUND(AVG(score)) as avg_score,
  COUNT(*) as tasks,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed
FROM dev_checklist
GROUP BY phase
ORDER BY phase;
```

### Reset Database

```bash
cd backend
mix ecto.reset
```

---

## 🔧 Troubleshooting

### PostgreSQL Not Running

```bash
# Check status
sudo service postgresql status

# Start if stopped
sudo service postgresql start

# Check logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

### Database Connection Refused

Check `backend/config/dev.exs`:
```elixir
config :global_sovereign, GlobalSovereign.Repo,
  database: "global_DB",
  username: "global-signal_-charter",
  password: "Mv@10111",
  hostname: "localhost",
  pool_size: 10
```

### Port Already in Use

```bash
# Backend (port 4000)
lsof -ti:4000 | xargs kill -9

# Frontend (port 5173)
lsof -ti:5173 | xargs kill -9
```

### Mix Dependencies Fail

```bash
cd backend
rm -rf _build deps
mix local.hex --force
mix local.rebar --force
mix deps.clean --all
mix deps.get
```

### Node Modules Issues

```bash
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

---

## 📚 Next Steps

1. **Read Documentation**:
   - [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Phased deployment with 90% gates
   - [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical deep dive
   - [CODEX.md](CODEX.md) - Seven Charters of sovereignty

2. **Start Phase 1**:
   - Open [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
   - Begin Phase 1 tasks
   - Check off completed items
   - Run `./scripts/scoring_tracker.exs` to track progress

3. **Set Up CI/CD**:
   - Push to GitHub
   - GitHub Actions will run automatically
   - Configure Fly.io secrets: `FLY_API_TOKEN`

4. **Join the Covenant**:
   - Contribute to open source
   - Deploy pilot towers in your community
   - Share feedback on GitHub Issues

---

## 🐆🦁🐇 Codex Invocation

> _"We begin not with code alone, but with covenant and resilience.  
> Let towers stand where communities gather.  
> Let data flow where knowledge thirsts.  
> Let systems crash, then rise wiser.  
> Ubuntu: I am because we are."_

**Guardians**:
- 🐆 **Leopard** (Resilience): Watches over fault tolerance
- 🦁 **Lion** (Sovereignty): Guards the 0.01% GDP covenant
- 🐇 **Hare** (Adaptation): Enables offline-first patterns

---

## 🔗 Important Links

- **GitHub**: (Your repo URL)
- **Fly.io Dashboard**: https://fly.io/dashboard
- **Documentation**: [/docs](docs/)
- **License**: [LICENSE](LICENSE)

---

## ⚡ Quick Commands Reference

```bash
# Setup
./scripts/setup.sh

# Start backend
cd backend && mix phx.server

# Start frontend
cd frontend && npm run dev

# Check scores
./scripts/scoring_tracker.exs

# Run tests
cd backend && mix test
cd frontend && npm test

# Deploy (production)
cd backend && fly deploy
```

---

**Inscribed**: 2026-01-04  
**Covenant Holder**: Mandlenkosi (global-signal_-charter)  
**Purpose**: Charter of Sovereign Unity

_May this system serve communities first, nations second, and technology last._
