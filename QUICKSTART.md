# Quick Start Guide

## Prerequisites

- Elixir 1.17+ and Erlang/OTP 26.2+
- Node.js 20+ and npm 10+
- PostgreSQL 16+
- Docker & Docker Compose (optional)
- Fly.io CLI (for deployment)

---

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/global-sovereign-system.git
cd global-sovereign-system
```

### 2. Backend Setup (Elixir/Phoenix)

```bash
cd backend

# Install dependencies
mix deps.get

# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Seed initial data
mix run priv/repo/seeds.exs

# Start Phoenix server
mix phx.server
```

Backend will be available at: `http://localhost:4000`

### 3. Frontend Setup (SvelteKit)

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend will be available at: `http://localhost:5173`

### 4. Verify Installation

```bash
# Health check
curl http://localhost:4000/health

# GraphQL playground
open http://localhost:4000/api/graphiql

# Frontend
open http://localhost:5173
```

---

## Environment Variables

### Backend (.env)

```bash
# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/global_sovereign_dev

# Phoenix
SECRET_KEY_BASE=your_secret_key_base_here
PHX_HOST=localhost
PORT=4000

# Authentication
GUARDIAN_SECRET_KEY=your_guardian_secret_here

# Cluster
CLUSTER_SECRET=sovereign_cluster_secret

# Encryption
CLOAK_KEY=base64_encoded_32_byte_key

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
```

Generate secrets:

```bash
# SECRET_KEY_BASE
mix phx.gen.secret

# CLOAK_KEY
dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64
```

### Frontend (.env)

```bash
PUBLIC_API_URL=http://localhost:4000
PUBLIC_GRAPHQL_URL=http://localhost:4000/api/graphql
PUBLIC_WS_URL=ws://localhost:4000/socket
```

---

## Docker Compose Setup (Alternative)

```yaml
# docker-compose.yml
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: global_sovereign_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  cassandra:
    image: cassandra:5.0
    environment:
      CASSANDRA_CLUSTER_NAME: sovereign_cluster
    ports:
      - "9042:9042"
    volumes:
      - cassandra_data:/var/lib/cassandra

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

volumes:
  postgres_data:
  cassandra_data:
  minio_data:
  redis_data:
  grafana_data:
  prometheus_data:
```

Start services:

```bash
docker-compose up -d
```

---

## Running Tests

### Backend Tests

```bash
cd backend

# Run all tests
mix test

# Run with coverage
mix test --cover

# Run chaos tests
mix test --only chaos

# Run specific test file
mix test test/global_sovereign/sync/supervisor_test.exs
```

### Frontend Tests

```bash
cd frontend

# Run unit tests
npm test

# Run with coverage
npm test -- --coverage

# Run e2e tests
npm run test:e2e
```

---

## Database Migrations

### Create Migration

```bash
mix ecto.gen.migration create_users_table
```

### Run Migrations

```bash
# Migrate up
mix ecto.migrate

# Rollback last migration
mix ecto.rollback

# Rollback to specific version
mix ecto.rollback --to 20240101120000

# Reset database
mix ecto.reset
```

---

## Fly.io Deployment

### Initial Setup

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Initialize app
cd backend
fly launch --name global-sovereign-api --region jnb

# Create Postgres cluster
fly postgres create --name global-sovereign-db --region jnb --initial-cluster-size 3

# Attach database
fly postgres attach global-sovereign-db

# Set secrets
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
fly secrets set GUARDIAN_SECRET_KEY=$(mix phx.gen.secret)
fly secrets set CLUSTER_SECRET=$(openssl rand -base64 32)
fly secrets set CLOAK_KEY=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64)
```

### Deploy

```bash
# Deploy backend
fly deploy

# Check status
fly status

# View logs
fly logs

# Scale
fly scale count 2 --region jnb

# Open dashboard
fly dashboard
```

### Frontend Deployment

```bash
cd frontend

# Build for production
npm run build

# Deploy to Fly
fly launch --name global-sovereign-web --region jnb
fly deploy
```

---

## Monitoring & Observability

### Access Grafana

```bash
# Local
open http://localhost:3000

# Production (via Fly proxy)
fly proxy 3000:3000 -a global-sovereign-api
```

Default credentials:
- Username: `admin`
- Password: `admin` (change immediately)

### View Metrics

```bash
# Prometheus metrics endpoint
curl http://localhost:4000/metrics

# Health check
curl http://localhost:4000/health

# Live dashboard
open http://localhost:4000/dashboard
```

---

## Common Tasks

### Generate GraphQL Schema

```bash
cd backend
mix absinthe.schema.json --schema GlobalSovereignWeb.Schema --pretty
```

### Generate TypeScript Types from GraphQL

```bash
cd frontend
npm run generate:types
```

### Run Interactive Console

```bash
# Backend (IEx)
cd backend
iex -S mix phx.server

# In IEx:
iex> GlobalSovereign.Sync.PriorityScheduler.schedule_content(:education, :p1, "https://example.com/video.mp4")
iex> :observer.start()  # Visual process monitor
```

### Database Console

```bash
# Local Postgres
psql -U postgres -d global_sovereign_dev

# Fly Postgres
fly postgres connect -a global-sovereign-db
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 4000
lsof -ti:4000

# Kill process
kill -9 $(lsof -ti:4000)
```

### Database Connection Issues

```bash
# Check Postgres is running
pg_isready

# Restart Postgres (macOS)
brew services restart postgresql@16

# Restart Postgres (Linux)
sudo systemctl restart postgresql
```

### Clear Cache

```bash
# Backend
cd backend
mix deps.clean --all
rm -rf _build

# Frontend
cd frontend
rm -rf node_modules
npm install
```

### Reset Everything

```bash
# Backend
cd backend
mix ecto.reset
mix deps.get
mix compile

# Frontend
cd frontend
rm -rf node_modules .svelte-kit build
npm install
npm run build
```

---

## Development Workflow

### Feature Development

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes
3. Run tests: `mix test` and `npm test`
4. Commit: `git commit -m "feat: add your feature"`
5. Push: `git push origin feature/your-feature`
6. Create PR on GitHub

### Code Style

```bash
# Backend formatting
mix format

# Backend linting
mix credo --strict

# Frontend linting
npm run lint

# Frontend formatting
npm run format
```

---

## Useful Links

- **Architecture**: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)
- **Security**: [docs/SECURITY.md](./docs/SECURITY.md)
- **Chaos Engineering**: [docs/CHAOS.md](./docs/CHAOS.md)
- **API Documentation**: http://localhost:4000/api/docs
- **Phoenix LiveDashboard**: http://localhost:4000/dashboard
- **Grafana**: http://localhost:3000

---

## Support

For issues, questions, or contributions:

1. Check existing issues: https://github.com/your-org/global-sovereign-system/issues
2. Create new issue with template
3. Join community Slack: https://sovereign.slack.com

---

**Built with sovereignty. Maintained with resilience. Archived in the Codex.**

*Guarded by the Leopard, Lion, and Hare*
