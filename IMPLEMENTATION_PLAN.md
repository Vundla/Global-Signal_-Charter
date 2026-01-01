# 🐆🦁🐇 UbuntuNet Global: Implementation Plan
## Charter of Sovereign Unity - Phased Deployment with 90% Review Gates

> _"Let it crash, then rise with wisdom. Every phase is a stepping stone, not a grave."_

---

## 📊 SCORING SYSTEM OVERVIEW

**Total Score: 0-500 points (100 per phase)**
- **90% Gate Threshold**: 450/500 minimum to proceed to production
- **Per-Phase Gate**: 90/100 minimum to advance to next phase
- **Review Cycle**: Automated checks + manual approval at each gate

### Scoring Categories (Per Phase)
| Category | Weight | Criteria |
|----------|--------|----------|
| **Code Quality** | 25% | Test coverage ≥90%, linting pass, documentation complete |
| **Security** | 25% | Vulnerability scan 100% pass, mTLS verified, RBAC enforced |
| **Resilience** | 25% | Chaos drill MTTR <30s, fault injection recovery, supervision tree health |
| **Offline Capability** | 15% | Service worker functional, IndexedDB sync operational, cache hit >80% |
| **Performance** | 10% | Latency <100ms p99, throughput >1000 req/s, resource usage <70% |

---

## 🎯 PHASE 1: FOUNDATION (Score: 0/100)
**Duration**: 2-3 weeks  
**Goal**: Core infrastructure, OTP supervision, database schema, CI/CD pipeline

### Tasks Checklist

#### 1.1 Database Initialization (25 points)
- [ ] **[5 pts]** Execute `init.sql` to create `global_DB` with `global-signal_-charter` ownership
- [ ] **[5 pts]** Verify PostGIS extension for tower geospatial queries
- [ ] **[5 pts]** Seed South Africa + Zimbabwe country data
- [ ] **[5 pts]** Configure synchronous replication for critical ledgers
- [ ] **[5 pts]** Set up automated backup to MinIO (hourly snapshots)

**Validation**:
```bash
psql -U global-signal_-charter -d global_DB -c "\dt" # List tables
psql -U global-signal_-charter -d global_DB -c "SELECT * FROM countries;"
```

#### 1.2 Elixir/Phoenix Core (25 points)
- [ ] **[10 pts]** Configure `GlobalSovereign.Repo` with `global_DB` credentials in `dev.exs`
- [ ] **[5 pts]** Implement `GlobalSovereign.Application` supervision tree with restart strategies
- [ ] **[5 pts]** Set up Phoenix endpoint with CORS for SvelteKit frontend
- [ ] **[5 pts]** Create `mix test` suite with ExUnit (target: 0% → 90% coverage)

**Test Command**:
```bash
cd backend && mix deps.get && mix ecto.create && mix test
```

#### 1.3 SvelteKit PWA Foundation (25 points)
- [ ] **[10 pts]** Configure `vite-plugin-pwa` with precaching for static assets
- [ ] **[5 pts]** Implement service worker with network-first API strategy
- [ ] **[5 pts]** Set up IndexedDB wrapper (`offline-db.ts`) for queued operations
- [ ] **[5 pts]** Create `+layout.svelte` with offline status indicator

**Validation**:
```bash
cd frontend && npm install && npm run build
# Check dist/manifest.json exists with precache entries
```

#### 1.4 CI/CD Pipeline (15 points)
- [ ] **[5 pts]** GitHub Actions workflow for Elixir tests (`mix test`)
- [ ] **[5 pts]** Frontend build + Lighthouse CI (PWA score >90)
- [ ] **[5 pts]** Automated security scanning (Sobelow for Elixir, npm audit)

**Gate Requirement**: All checks must pass before Phase 2

#### 1.5 Documentation (10 points)
- [ ] **[5 pts]** Update ARCHITECTURE.md with deployed infrastructure details
- [ ] **[5 pts]** Create API.md documenting Phoenix endpoints + SvelteKit routes

---

### 🚦 PHASE 1 REVIEW GATE
**Automated Checks**:
- ✅ Database schema exists with all 10+ tables
- ✅ Phoenix server starts without errors (`mix phx.server`)
- ✅ SvelteKit builds successfully with service worker
- ✅ CI pipeline passes (tests + security scans)
- ✅ Code coverage ≥90% (Elixir + TypeScript)

**Manual Review** (by reviewer):
- Architecture alignment with Codex Charters
- Database schema supports 0.01% GDP ledger
- Offline-first patterns correctly implemented

**Scoring Rubric**:
```
Code Quality: ___ / 25 (test coverage %, docs complete?)
Security:     ___ / 25 (scans pass, credentials secured?)
Resilience:   ___ / 25 (supervision tree restarts tested?)
Offline:      ___ / 15 (service worker functional?)
Performance:  ___ / 10 (build time <2 min?)
────────────────────
PHASE 1 TOTAL: ___ / 100
```

**Minimum to Proceed**: 90/100  
**Reviewer**: _______________  
**Date**: _______________

---

## 🗄️ PHASE 2: DATA & CACHING (Score: 0/100)
**Duration**: 2 weeks  
**Goal**: Multi-tier caching, Cassandra replication, IPFS integration

### Tasks Checklist

#### 2.1 Local Caching Layer (30 points)
- [ ] **[10 pts]** Implement NGINX/Varnish local CDN for static assets
- [ ] **[10 pts]** Configure NVMe hot cache for frequently accessed content
- [ ] **[5 pts]** Set up cache eviction policies (LRU for warm archive)
- [ ] **[5 pts]** Add cache hit rate telemetry to PromEx

**Target**: Cache hit rate >80% for community content

#### 2.2 Cassandra Multi-DC Replication (30 points)
- [ ] **[10 pts]** Deploy Cassandra cluster (Johannesburg, Frankfurt, London)
- [ ] **[10 pts]** Configure `NetworkTopologyStrategy` with RF=3 per DC
- [ ] **[5 pts]** Create keyspace for time-series telemetry data
- [ ] **[5 pts]** Test cross-DC consistency with `cqlsh` queries

**Validation**:
```bash
nodetool status # Should show 3 DCs with UP nodes
```

#### 2.3 IPFS Integration (20 points)
- [ ] **[10 pts]** Deploy IPFS daemon on edge towers
- [ ] **[5 pts]** Implement content-addressed sync in `GlobalSovereign.Sync.Supervisor`
- [ ] **[5 pts]** Pin critical datasets (education content, health records)

#### 2.4 MinIO Object Storage (10 points)
- [ ] **[5 pts]** Configure MinIO with erasure coding (EC:4+2)
- [ ] **[5 pts]** Set up automated PostgreSQL backup to MinIO buckets

#### 2.5 Delta Sync Implementation (10 points)
- [ ] **[10 pts]** Build delta sync algorithm (only transfer changed blocks)

---

### 🚦 PHASE 2 REVIEW GATE
**Automated Checks**:
- ✅ Cache hit rate >80% in staging environment
- ✅ Cassandra cluster shows 100% node availability
- ✅ IPFS pin count >1000 CIDs for test data
- ✅ MinIO stores backups with checksums verified

**Manual Review**:
- Replication lag <5 seconds between DCs
- Content verification matches SHA-256 hashes
- Offline mode still functional when upstream fails

**Scoring Rubric**:
```
Code Quality: ___ / 25
Security:     ___ / 25 (MinIO ACLs configured?)
Resilience:   ___ / 25 (Cassandra node failure tested?)
Offline:      ___ / 15 (IPFS serves content when offline?)
Performance:  ___ / 10 (cache latency <10ms?)
────────────────────
PHASE 2 TOTAL: ___ / 100
```

**Minimum to Proceed**: 90/100

---

## 🤖 PHASE 3: AI OBSERVABILITY & SECURITY (Score: 0/100)
**Duration**: 3 weeks  
**Goal**: Zero-trust enforcement, mTLS, AI anomaly detection, RBAC

### Tasks Checklist

#### 3.1 Zero-Trust Architecture (30 points)
- [ ] **[15 pts]** Implement mTLS for all service-to-service communication
- [ ] **[10 pts]** Deploy WireGuard tunnels for tower-to-cloud links
- [ ] **[5 pts]** Configure certificate rotation (Let's Encrypt + cert-manager)

**Validation**:
```bash
openssl s_client -connect tower01.ubuntunet.global:443 -showcerts
```

#### 3.2 RBAC/ABAC Policies (25 points)
- [ ] **[10 pts]** Define roles: `tower_operator`, `community_admin`, `national_auditor`
- [ ] **[10 pts]** Implement attribute-based access control (ABAC) for data segregation
- [ ] **[5 pts]** Create policy enforcement point in Phoenix middleware

#### 3.3 AI Observability (25 points)
- [ ] **[10 pts]** Train anomaly detection model on telemetry data (LSTM or Isolation Forest)
- [ ] **[10 pts]** Deploy AI agent in `GlobalSovereign.AIObservability` GenServer
- [ ] **[5 pts]** Set up alerts for anomalies (Grafana + PagerDuty)

**Target**: False positive rate <5%

#### 3.4 Audit Logging (15 points)
- [ ] **[10 pts]** Implement tamper-evident audit logs (append-only with hash chains)
- [ ] **[5 pts]** Store audit trail in `audit_log` table with JSONB diffs

#### 3.5 Security Scanning (5 points)
- [ ] **[5 pts]** Run penetration test (OWASP ZAP or Burp Suite)

---

### 🚦 PHASE 3 REVIEW GATE
**Automated Checks**:
- ✅ mTLS handshake successful for all services
- ✅ RBAC denies unauthorized access (403 Forbidden)
- ✅ AI model detects injected anomalies >95% accuracy
- ✅ Security scan shows 0 critical vulnerabilities

**Manual Review**:
- Verify WireGuard tunnels encrypt all traffic
- Test privilege escalation attempts (should fail)
- Review audit logs for completeness

**Scoring Rubric**:
```
Code Quality: ___ / 25
Security:     ___ / 25 (pen test passed?)
Resilience:   ___ / 25 (cert rotation tested?)
Offline:      ___ / 15 (offline auth works?)
Performance:  ___ / 10 (mTLS overhead <5ms?)
────────────────────
PHASE 3 TOTAL: ___ / 100
```

**Minimum to Proceed**: 90/100

---

## 🔥 PHASE 4: CHAOS ENGINEERING (Score: 0/100)
**Duration**: 2 weeks  
**Goal**: Fault injection, game days, MTTR <30s, "Crash it if you can"

### Tasks Checklist

#### 4.1 Chaos Toolkit Setup (20 points)
- [ ] **[10 pts]** Install Chaos Toolkit with Kubernetes extension
- [ ] **[10 pts]** Create experiment manifests for network partitions, pod kills

#### 4.2 Fault Injection Scenarios (40 points)
- [ ] **[10 pts]** **Scenario 1**: Kill Phoenix primary node (test supervisor restart)
- [ ] **[10 pts]** **Scenario 2**: Partition Cassandra DC (test eventual consistency)
- [ ] **[10 pts]** **Scenario 3**: Drain tower battery to 10% (test power-aware shedding)
- [ ] **[10 pts]** **Scenario 4**: Inject 50% packet loss on fibre link (test degraded mode)

**Target**: MTTR <30 seconds for all scenarios

#### 4.3 Game Day Drills (25 points)
- [ ] **[15 pts]** Conduct quarterly game day with stakeholders (simulate regional outage)
- [ ] **[10 pts]** Document postmortem with blame-free analysis

#### 4.4 Metrics & Dashboards (15 points)
- [ ] **[10 pts]** Build Grafana dashboard for MTTD/MTTR/availability
- [ ] **[5 pts]** Set SLO targets (99.9% uptime for critical services)

---

### 🚦 PHASE 4 REVIEW GATE
**Automated Checks**:
- ✅ All 4 chaos scenarios recover within 30 seconds
- ✅ No data loss during fault injection
- ✅ Prometheus captures MTTR metrics <30s

**Manual Review**:
- Verify supervisor tree restarts correctly
- Test edge cases (multiple simultaneous failures)
- Review postmortem action items

**Scoring Rubric**:
```
Code Quality: ___ / 25
Security:     ___ / 25 (chaos doesn't expose secrets?)
Resilience:   ___ / 25 (MTTR <30s for all tests?)
Offline:      ___ / 15 (tower survives partition?)
Performance:  ___ / 10 (recovery doesn't spike latency?)
────────────────────
PHASE 4 TOTAL: ___ / 100
```

**Minimum to Proceed**: 90/100

---

## 🌍 PHASE 5: COMMUNITY ROLLOUT (Score: 0/100)
**Duration**: 4 weeks  
**Goal**: Pilot towers in South Africa + Zimbabwe, community onboarding, profit distribution

### Tasks Checklist

#### 5.1 Hardware Deployment (30 points)
- [ ] **[15 pts]** Deploy Tower #1 (Johannesburg, Soweto community center)
- [ ] **[15 pts]** Deploy Tower #2 (Harare, Zimbabwe rural school)

**Validation**:
- Solar+battery sustains 24h operation
- Coverage radius reaches 5km
- Active users >100 per tower

#### 5.2 Community Onboarding (25 points)
- [ ] **[10 pts]** Train local operators on tower maintenance
- [ ] **[10 pts]** Distribute WiFi access credentials to schools/clinics
- [ ] **[5 pts]** Set up community dashboard (SvelteKit portal)

#### 5.3 Profit Distribution (20 points)
- [ ] **[10 pts]** Execute first monthly profit-sharing (50% communities, 30% nations, 20% maintenance)
- [ ] **[10 pts]** Publish transparent ledger to `profit_ledger` table

#### 5.4 Feedback Loop (15 points)
- [ ] **[10 pts]** Collect user feedback via surveys (target: 500 responses)
- [ ] **[5 pts]** Iterate on UX based on community input

#### 5.5 National Covenant Signing (10 points)
- [ ] **[10 pts]** Secure commitment from South African Government of National Unity

---

### 🚦 PHASE 5 REVIEW GATE
**Automated Checks**:
- ✅ Towers report >99% uptime for 30 days
- ✅ Community dashboard shows >1000 active users
- ✅ Profit ledger audit trail verified

**Manual Review**:
- Visit towers physically (site inspection)
- Interview community beneficiaries
- Verify offline mode works when ISP disconnects

**Scoring Rubric**:
```
Code Quality: ___ / 25
Security:     ___ / 25 (community data protected?)
Resilience:   ___ / 25 (towers survive power outage?)
Offline:      ___ / 15 (100% operational offline?)
Performance:  ___ / 10 (user satisfaction >90%?)
────────────────────
PHASE 5 TOTAL: ___ / 100
```

**Minimum to Proceed**: 90/100

---

## 📈 MASTER SCORECARD

| Phase | Status | Score | Gate Passed? | Reviewer | Date |
|-------|--------|-------|--------------|----------|------|
| **1. Foundation** | 🔴 Not Started | 0/100 | ❌ | - | - |
| **2. Data & Caching** | 🔴 Not Started | 0/100 | ❌ | - | - |
| **3. AI & Security** | 🔴 Not Started | 0/100 | ❌ | - | - |
| **4. Chaos Engineering** | 🔴 Not Started | 0/100 | ❌ | - | - |
| **5. Community Rollout** | 🔴 Not Started | 0/100 | ❌ | - | - |
| **TOTAL** | - | **0/500** | ❌ | - | - |

**Production Readiness**: 0/500 (Need 450+ to deploy)

---

## 🔐 DATABASE CONFIGURATION SUMMARY

```sql
Database Name:     global_DB
Username:          global-signal_-charter
Password:          Mv@10111
Schema Owner:      global-signal_-charter (public schema)
Connection String: postgresql://global-signal_-charter:Mv@10111@localhost:5432/global_DB
```

**Initialization Steps**:
```bash
# 1. Create database and role (as superuser)
sudo -u postgres psql -f backend/priv/repo/init.sql

# 2. Verify ownership
psql -U global-signal_-charter -d global_DB -c "\dn+"

# 3. Run Phoenix migrations
cd backend && mix ecto.migrate

# 4. Seed test data
mix run priv/repo/seeds.exs
```

---

## 🔄 AUDIT & ROLLBACK PROCEDURES

### Continuous Auditing
- **Automated**: Every database write logs to `audit_log` table
- **Manual Review**: Weekly review of high-privilege actions
- **Immutability**: Audit logs are append-only (no DELETE/UPDATE)

### Rollback Protocol
If any phase scores <90/100:
1. **Halt Progression**: Do not proceed to next phase
2. **Root Cause Analysis**: Document what failed
3. **Fix & Retest**: Address issues, re-run automated checks
4. **Re-Score**: Update scorecard, require 90+ before advancing

### Emergency Rollback
If production issue detected:
```bash
# Rollback database migration
mix ecto.rollback --step 1

# Redeploy previous Fly.io version
fly deploy --image registry.fly.io/ubuntunet:previous

# Notify stakeholders via PagerDuty
```

---

## 🎯 NEXT IMMEDIATE ACTIONS

1. **Initialize Database**:
   ```bash
   cd backend
   sudo -u postgres psql -f priv/repo/init.sql
   ```

2. **Start Backend**:
   ```bash
   mix deps.get
   mix ecto.create
   mix phx.server
   ```

3. **Start Frontend**:
   ```bash
   cd ../frontend
   npm install
   npm run dev
   ```

4. **Begin Phase 1 Checklist**:
   - Open this file
   - Check off tasks as completed
   - Update Master Scorecard
   - Request review when 90/100 achieved

---

## 🐆🦁🐇 CODEX INVOCATION

> _"We begin not with code alone, but with covenant and resilience.  
> Let towers stand where communities gather.  
> Let data flow where knowledge thirsts.  
> Let systems crash, then rise wiser.  
> Ubuntu: I am because we are."_

**Guardians of This Charter**:
- 🐆 **Leopard** (Resilience): Watches over fault tolerance, ensuring systems rise from crashes
- 🦁 **Lion** (Sovereignty): Guards the 0.01% GDP covenant, protecting community ownership
- 🐇 **Hare** (Adaptation): Enables offline-first patterns, thriving when the world disconnects

---

**Inscribed**: 2026-01-04  
**Next Review**: After Phase 1 completion  
**Covenant Holder**: Mandlenkosi (global-signal_-charter)  
**Purpose**: Charter of Sovereign Unity - Offline connectivity for all

_May this plan serve the communities first, the nations second, and technology last._
