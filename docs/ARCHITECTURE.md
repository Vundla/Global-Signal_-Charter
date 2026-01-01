# System Architecture

## Overview

The Global Sovereign Offline System is built on three pillars:

1. **Fault Tolerance**: Elixir/BEAM supervision trees ensure graceful failures
2. **Offline-First**: SvelteKit PWA serves communities even when disconnected
3. **Redundancy by Design**: Every component has multiple fallback strategies

---

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Community Devices                         │
│              (Phones, Tablets, Laptops)                      │
└───────────────────────┬─────────────────────────────────────┘
                        │ Wi-Fi 6/6E
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                   Local Mesh Network                         │
│         (APs, VLANs: public/admin/critical)                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
┌────────────────┐              ┌────────────────┐
│  Edge Router   │              │  Power System  │
│  (pfSense/OPN) │              │  (Solar+UPS)   │
└────────┬───────┘              └────────────────┘
         │
         ├─ Fibre (primary)
         ├─ LTE/5G (secondary)
         └─ Satellite (tertiary)
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Sovereign Edge Server                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Control Plane (Elixir/BEAM/OTP)               │ │
│  │                                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │ │
│  │  │   Phoenix    │  │     Sync     │  │    Cache    │ │ │
│  │  │ Orchestrator │  │  Supervisor  │  │   Warmers   │ │ │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │ │
│  │                                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐                  │ │
│  │  │    Event     │  │  AI Observer │                  │ │
│  │  │   Gateway    │  │    Agents    │                  │ │
│  │  └──────────────┘  └──────────────┘                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │               Data Layer                               │ │
│  │                                                        │ │
│  │  ┌──────────┐  ┌──────────┐  ┌───────┐  ┌─────────┐ │ │
│  │  │ Postgres │  │ Cassandra│  │ MinIO │  │  IPFS   │ │ │
│  │  │ (primary)│  │ (multi-DC│  │ (S3)  │  │ (pins)  │ │ │
│  │  └──────────┘  └──────────┘  └───────┘  └─────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Caching Layer (NGINX/Varnish)                 │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Frontend (SvelteKit PWA)                        │
│  • Service Workers (cache strategies)                       │
│  • IndexedDB (local persistence)                            │
│  • Background Sync (queued operations)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Control Plane Details

### Phoenix Orchestrator

```elixir
# Supervision tree structure
GlobalSovereign.Application
├── Phoenix.Endpoint (HTTP/WebSocket)
├── Phoenix.PubSub (real-time updates)
├── GlobalSovereign.Orchestrator.Supervisor
│   ├── AdminPortal (role-based UI)
│   ├── APIGateway (REST/GraphQL)
│   ├── AuthManager (mTLS, RBAC)
│   └── Dashboard (community metrics)
├── GlobalSovereign.Sync.Supervisor
│   ├── PriorityScheduler (health, education, fintech)
│   ├── DeltaSyncer (IPFS + HTTP warmup)
│   ├── LinkHealthMonitor (adaptive throttling)
│   └── ContentVerifier (SHA-256, signatures)
├── GlobalSovereign.Cache.Supervisor
│   ├── WarmupWorker (prefetch critical datasets)
│   ├── EvictionPolicy (LRU with priority weighting)
│   └── IntegrityChecker (hash validation)
├── GlobalSovereign.Events.Supervisor
│   ├── NATS.Consumer (idempotent handlers)
│   ├── Kafka.Producer (event publishing)
│   └── CircuitBreaker (failure isolation)
└── GlobalSovereign.AI.Supervisor
    ├── AnomalyDetector (baseline modeling)
    ├── PolicyEnforcer (throttle, quarantine)
    └── IncidentTriager (alert routing)
```

### Sync Supervisor Logic

**Priority Tiers:**
1. **Critical (P0)**: Health advisories, emergency alerts
2. **High (P1)**: Educational content, fintech ledger updates
3. **Medium (P2)**: Community news, entertainment
4. **Low (P3)**: Archives, historical data

**Sync Strategy:**
```elixir
defmodule GlobalSovereign.Sync.Strategy do
  @doc """
  Adaptive sync based on link health:
  - Fibre available: sync all priorities
  - LTE/5G only: sync P0, P1
  - Satellite only: sync P0 only
  - Offline: serve cache
  """
  def sync_plan(link_status, bandwidth_mbps) do
    case {link_status, bandwidth_mbps} do
      {:fibre, bw} when bw > 50 -> [:p0, :p1, :p2, :p3]
      {:lte, bw} when bw > 10 -> [:p0, :p1, :p2]
      {:lte, _} -> [:p0, :p1]
      {:satellite, _} -> [:p0]
      {:offline, _} -> []
    end
  end
end
```

---

## Data Layer Architecture

### PostgreSQL (Transactional)

```yaml
Primary:
  location: edge-tower-01
  replication: synchronous to edge-tower-02
  use_cases:
    - fintech ledgers (double-entry accounting)
    - user authentication and sessions
    - governance records (allocations, audits)

Read Replicas:
  - edge-tower-03 (async replication)
  - edge-tower-04 (async replication)
  use_cases:
    - portal queries
    - dashboard aggregations
    - analytics

Backup Strategy:
  - continuous WAL archiving to MinIO
  - daily PITR snapshots (30-day retention)
  - weekly full backups (1-year retention)
```

### Cassandra (Catalog & Time-Series)

```yaml
Cluster:
  datacenters:
    - dc-africa (RF=3)
    - dc-europe (RF=3)
  consistency: LOCAL_QUORUM (reads/writes)
  
Use Cases:
  - content catalog (metadata, indices)
  - time-series metrics (observability)
  - community activity logs

Partition Keys:
  content: [country_code, category, date]
  metrics: [service_name, metric_type, timestamp]
```

### MinIO (Object Storage)

```yaml
Pools:
  - name: critical
    erasure_coding: EC:6+3
    regions: [africa, europe, us-east]
    
  - name: general
    erasure_coding: EC:4+2
    regions: [africa, europe]

Buckets:
  - education (videos, PDFs, course materials)
  - health (advisories, treatment guides)
  - fintech (app bundles, transaction logs)
  - governance (charters, audit trails)

Security:
  - signed URLs (5-minute expiry)
  - bucket policies (least privilege)
  - versioning enabled
  - lifecycle rules (archive to cold storage after 90 days)
```

### IPFS (Immutable Datasets)

```yaml
Pinning Strategy:
  - critical datasets: 5+ nodes
  - general datasets: 3 nodes
  - archival datasets: 2 nodes + cold storage

Content Types:
  - educational materials (CID-based distribution)
  - health advisories (tamper-evident)
  - governance charters (audit trail)

Integration:
  - IPFS HTTP gateway for legacy clients
  - libp2p for peer-to-peer sync
  - content routing via DHT
```

---

## Caching Architecture

### NGINX/Varnish Layer

```nginx
# /etc/nginx/conf.d/sovereign-cache.conf

proxy_cache_path /var/cache/nginx/sovereign
                 levels=1:2
                 keys_zone=sovereign_cache:100m
                 max_size=50g
                 inactive=90d
                 use_temp_path=off;

upstream phoenix_backend {
    least_conn;
    server 127.0.0.1:4000 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:4001 max_fails=3 fail_timeout=30s backup;
}

server {
    listen 80;
    server_name sovereign.local;

    location /api/ {
        proxy_pass http://phoenix_backend;
        proxy_cache sovereign_cache;
        proxy_cache_valid 200 60m;
        proxy_cache_valid 404 10m;
        proxy_cache_use_stale error timeout updating;
        
        # Prioritize cache during degraded connectivity
        proxy_cache_background_update on;
        
        add_header X-Cache-Status $upstream_cache_status;
    }

    location /static/ {
        proxy_cache sovereign_cache;
        proxy_cache_valid 200 7d;
        proxy_ignore_headers Cache-Control Expires;
        add_header Cache-Control "public, immutable, max-age=604800";
    }
}
```

**Cache Hierarchy:**
1. **Browser Cache** (Service Worker): 7 days for static, 1 hour for API
2. **Edge Cache** (NGINX): 90 days inactive, 50GB limit
3. **Origin Cache** (Phoenix): ETS-based hot cache
4. **Database**: Postgres/Cassandra as source of truth

---

## Network Topology

### Multi-Tier Connectivity

```
         Internet
             │
    ┌────────┴────────┐
    │  Policy Router  │ (pfSense/OPNsense)
    │   (Failover)    │
    └────────┬────────┘
             │
    ┌────────┴────────────────────┐
    │   Priority 1: Fibre (1Gbps) │
    │   Priority 2: LTE/5G (100M) │
    │   Priority 3: Satellite (5M)│
    └────────┬────────────────────┘
             │
      Local Mesh Network
       (Wi-Fi 6/6E)
             │
    ┌────────┴────────┐
    │  VLAN Segmentation
    ├─ Public (guest access)
    ├─ Admin (operators only)
    └─ Critical (health/fintech services)
```

### VLANs Configuration

| VLAN | ID  | Purpose            | Bandwidth Limit | Priority |
|------|-----|--------------------|-----------------|----------|
| Public | 10 | Community access  | 50 Mbps/user    | Normal   |
| Admin  | 20 | Operations        | Unlimited       | High     |
| Critical | 30 | Health/Fintech   | Guaranteed 100M | Highest  |

---

## Power Management

### Solar + Battery Architecture

```
Solar Array (10kW)
    ↓
MPPT Controller
    ↓
Battery Bank (48V, 200Ah)
    ↓
Inverter + UPS
    ↓
    ├─ Critical Load (5kW): Servers, Networking
    ├─ Normal Load (3kW): APs, Peripherals
    └─ Shedable Load (2kW): HVAC, Lighting
```

### Power-Aware Service Shedding

```elixir
defmodule GlobalSovereign.Power.Manager do
  @doc """
  Shed services based on battery state:
  - 100-50%: All services
  - 50-20%: Shed normal load, keep critical
  - 20-10%: Shed all but health/fintech
  - <10%: Graceful shutdown, cache only
  """
  def adjust_services(battery_percent) do
    cond do
      battery_percent > 50 -> :all_services
      battery_percent > 20 -> :critical_only
      battery_percent > 10 -> :minimal_services
      true -> :graceful_shutdown
    end
  end
end
```

---

## Observability Stack

### Metrics Collection

```elixir
# lib/global_sovereign/telemetry.ex
defmodule GlobalSovereign.Telemetry do
  use PromEx, otp_app: :global_sovereign

  @impl true
  def plugins do
    [
      PromEx.Plugins.Application,
      PromEx.Plugins.Beam,
      {PromEx.Plugins.Phoenix, router: GlobalSovereignWeb.Router},
      {PromEx.Plugins.Ecto, repos: [GlobalSovereign.Repo]},
      GlobalSovereign.Telemetry.Plugins.Sync,
      GlobalSovereign.Telemetry.Plugins.Cache,
      GlobalSovereign.Telemetry.Plugins.Power
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "prometheus",
      default_selected_interval: "30s"
    ]
  end
end
```

### Grafana Dashboards

**Community Dashboard (Public):**
- Tower uptime (SLA: 99.9%)
- Cached content availability
- Sync status (last successful sync time)
- Power status (battery %, solar generation)

**Operations Dashboard (Admin):**
- BEAM VM metrics (schedulers, memory, processes)
- Database replication lag
- Cache hit ratio (target: >80%)
- Network throughput by tier (fibre/LTE/satellite)
- AI anomaly alerts

**Governance Dashboard (Council):**
- Profit allocation by nation
- Community impact metrics (users served, content accessed)
- Deployment progress (towers operational vs planned)
- Financial transparency (fund balance, expenditures)

---

## Security Architecture

### Zero-Trust Principles

```
Every request is authenticated and authorized.
No implicit trust between services.
Least privilege by default.
Continuous verification.
```

### mTLS Implementation

```elixir
# config/runtime.exs
config :global_sovereign, GlobalSovereignWeb.Endpoint,
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: System.fetch_env!("SSL_CERT_PATH"),
    keyfile: System.fetch_env!("SSL_KEY_PATH"),
    cacertfile: System.fetch_env!("SSL_CA_PATH"),
    verify: :verify_peer,
    fail_if_no_peer_cert: true
  ]
```

### WireGuard Mesh

```ini
# /etc/wireguard/wg0.conf (Edge Tower)
[Interface]
PrivateKey = <tower_private_key>
Address = 10.99.0.1/24
ListenPort = 51820

[Peer]
# Secondary Tower
PublicKey = <tower2_public_key>
AllowedIPs = 10.99.0.2/32
Endpoint = tower2.sovereign.network:51820

[Peer]
# Regional Hub
PublicKey = <hub_public_key>
AllowedIPs = 10.99.0.0/16
Endpoint = hub.sovereign.network:51820
PersistentKeepalive = 25
```

---

## Deployment Architecture (Fly.io)

### Multi-Region Setup

```yaml
# fly.toml
app = "global-sovereign-api"
primary_region = "jnb" # Johannesburg

[build]
  builder = "hexpm/elixir"
  buildpacks = ["hexpm/elixir"]

[env]
  PHX_HOST = "api.sovereign.network"
  PORT = "8080"

[[services]]
  http_checks = []
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"

  [[services.ports]]
    force_https = true
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    grace_period = "10s"
    interval = "15s"
    restart_limit = 0
    timeout = "2s"

# Regions
[regions]
  jnb = 2  # Johannesburg (primary)
  fra = 1  # Frankfurt (secondary)
  lhr = 1  # London (secondary)
```

### Scaling Strategy

```bash
# Scale Phoenix API
fly scale count 2 --region jnb
fly scale count 1 --region fra
fly scale count 1 --region lhr

# Scale based on metrics
fly autoscale set min=2 max=10 --region jnb
fly autoscale balanced cpu=70 mem=80
```

---

## Fault Tolerance Patterns

### Circuit Breaker

```elixir
defmodule GlobalSovereign.CircuitBreaker do
  use GenServer

  @failure_threshold 5
  @timeout_ms 60_000

  def call(service, func, args) do
    GenServer.call(__MODULE__, {:execute, service, func, args})
  end

  def handle_call({:execute, service, func, args}, _from, state) do
    case state[service] do
      :open ->
        {:reply, {:error, :circuit_open}, state}

      _ ->
        case apply(func, args) do
          {:ok, result} ->
            {:reply, {:ok, result}, reset_failures(state, service)}

          {:error, reason} ->
            new_state = increment_failures(state, service)
            {:reply, {:error, reason}, new_state}
        end
    end
  end
end
```

### Exponential Backoff

```elixir
defmodule GlobalSovereign.Retry do
  def with_backoff(func, max_attempts \\ 5) do
    do_retry(func, max_attempts, 1)
  end

  defp do_retry(func, 0, _attempt), do: {:error, :max_retries}

  defp do_retry(func, remaining, attempt) do
    case func.() do
      {:ok, result} ->
        {:ok, result}

      {:error, _reason} ->
        backoff_ms = :math.pow(2, attempt) * 1000 + :rand.uniform(1000)
        Process.sleep(trunc(backoff_ms))
        do_retry(func, remaining - 1, attempt + 1)
    end
  end
end
```

### Supervision Strategy

```elixir
defmodule GlobalSovereign.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # Critical services: restart always
      {GlobalSovereign.Repo, []},
      {Phoenix.PubSub, name: GlobalSovereign.PubSub},
      GlobalSovereignWeb.Endpoint,

      # Supervised workers: restart on failure
      {GlobalSovereign.Sync.Supervisor, strategy: :one_for_one},
      {GlobalSovereign.Cache.Supervisor, strategy: :one_for_one},
      {GlobalSovereign.Events.Supervisor, strategy: :one_for_one},

      # Transient services: restart only on abnormal exit
      {GlobalSovereign.AI.Supervisor, restart: :transient}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

---

## Next Steps

- [Deployment Guide](./DEPLOYMENT.md)
- [Security Hardening](./SECURITY.md)
- [Chaos Engineering](./CHAOS.md)
- [Frontend Implementation](./FRONTEND.md)
