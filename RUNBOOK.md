# RUNBOOK.md — Operational Rituals for Global Sovereign System

## 🔧 1. Incident Response Protocol

### Severity Levels

| Severity | Trigger Example | Action | Response Time |
|----------|----------------|---------|---------------|
| **Critical** | API returns 5xx > 5% for 5 min | Page on-call, investigate immediately, rollback if needed | Immediate |
| **High** | NATS stream lag > 1000 msgs | Restart consumer, inspect logs, scale if needed | < 15 min |
| **Medium** | Project creation fails in 3+ regions | Triage, log issue, notify team | < 1 hour |
| **Low** | Metrics endpoint down | Restart PromEx, check logs | < 4 hours |

### Response Steps
1. **Acknowledge**: Confirm alert received
2. **Assess**: Check dashboards, logs, traces
3. **Act**: Execute recovery ritual
4. **Announce**: Update status page
5. **Document**: Log incident in audit trail

---

## 🧪 2. Health Check Rituals

### System Health Endpoints
```bash
# Metrics endpoint (Prometheus scrape)
curl http://localhost:4000/metrics
# Expected: 200 OK with Prometheus format

# GraphQL API health
curl -X POST http://localhost:4000/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'
# Expected: Schema introspection response

# Phoenix health check
curl http://localhost:4000/api/healthcheck
# Expected: {"status":"ok"}

# Database connectivity
mix run -e "GlobalSovereign.Repo.query!(\"SELECT 1\")"
# Expected: No errors

# NATS JetStream health
nats stream info audit
nats stream info covenant
nats consumer ls audit
# Expected: Stream stats and consumer list
```

### Automated Health Checks
```elixir
# In production, configure health check endpoint
def health_check do
  checks = [
    database: check_database(),
    nats: check_nats(),
    cache: check_cachex(),
    metrics: check_promex()
  ]
  
  all_healthy = Enum.all?(checks, fn {_name, result} -> result == :ok end)
  status = if all_healthy, do: :healthy, else: :degraded
  
  {status, checks}
end
```

---

## 📡 3. Observability Dashboards

### Dashboard Access
- **Grafana**: `http://localhost:3000`
- **Jaeger**: `http://localhost:16686`
- **Prometheus**: `http://localhost:9090`

### Key Dashboards

#### 1. Covenant Overview
**Purpose**: Monitor business metrics
- Total projects across all countries
- Countries in system
- Covenant fund growth (GDP sum)
- Project creation rate (per hour)

**Key Metrics**:
```promql
# Total countries
global_sovereign_covenant_countries_total

# Total projects
global_sovereign_covenant_projects_total

# Covenant fund (GDP sum)
global_sovereign_covenant_fund_total

# Project creation rate
rate(global_sovereign_covenant_projects_total[1h])
```

#### 2. Phoenix Metrics
**Purpose**: Monitor API performance
- Request rate (req/sec)
- Latency (p50, p95, p99)
- Error rate (4xx, 5xx)
- Response time by endpoint

**Key Metrics**:
```promql
# Request rate
rate(phoenix_http_request_total[5m])

# Latency p95
histogram_quantile(0.95, phoenix_http_request_duration_seconds_bucket)

# Error rate
rate(phoenix_http_request_total{status=~"5.."}[5m])
```

#### 3. Ecto Performance
**Purpose**: Monitor database operations
- Query execution time
- Query count
- Pool size and checkout time
- Slow queries (> 500ms)

**Key Metrics**:
```promql
# Query time p95
histogram_quantile(0.95, ecto_query_duration_seconds_bucket)

# Slow queries
ecto_query_duration_seconds_bucket{le="0.5"}

# DB pool size
ecto_connection_pool_size
```

#### 4. BEAM Health
**Purpose**: Monitor VM performance
- Memory usage (total, processes, ETS)
- Reductions per second
- Process count
- Garbage collection frequency

**Key Metrics**:
```promql
# Total memory
vm_memory_total_bytes

# Process count
vm_total_processes

# Reductions (CPU work)
rate(vm_total_reductions[1m])
```

#### 5. NATS Streams
**Purpose**: Monitor event streaming
- Stream lag (pending messages)
- Consumer throughput
- Message delivery rate
- Stream health status

---

## 🔔 4. Alert Playbooks

### Alert: High 5xx Error Rate
**Trigger**: > 5% 5xx responses in 5 minutes

**Playbook**:
1. Check recent deployments: `fly releases --app global-sovereign`
2. Review LoggerJSON logs:
   ```bash
   tail -f /var/log/phoenix.json | jq 'select(.status >= 500)'
   ```
3. Find failing trace in Jaeger:
   - Open Jaeger UI
   - Filter by `http.status_code=500`
   - Identify root cause span
4. Check error pattern:
   ```elixir
   GlobalSovereign.Repo.query!("SELECT * FROM error_logs WHERE created_at > NOW() - INTERVAL '5 minutes'")
   ```
5. **Recovery**:
   - If deployment-related: `fly rollback`
   - If code bug: Hotfix + redeploy
   - If DB-related: Check connection pool, restart if needed
6. Notify: Post incident summary to #on-call

---

### Alert: Covenant Fund Drop > 10%
**Trigger**: Covenant fund delta > 10% in 1 hour

**Playbook**:
1. Query recent GDP updates:
   ```sql
   SELECT * FROM countries_phase4 
   WHERE updated_at > NOW() - INTERVAL '1 hour'
   ORDER BY updated_at DESC;
   ```
2. Check project deletions:
   ```sql
   SELECT * FROM projects_phase4 
   WHERE deleted_at > NOW() - INTERVAL '1 hour';
   ```
3. Review audit logs:
   ```bash
   nats stream get audit --last 100 | grep -E "country.update|project.delete"
   ```
4. Check for admin actions:
   ```elixir
   from(u in User, join: a in AuditLog, on: a.user_id == u.id, 
        where: u.role == :admin and a.inserted_at > ago(1, "hour"))
   ```
5. **Recovery**:
   - If data error: Rollback migration or restore from backup
   - If legitimate: Notify finance guardian
   - If suspicious: Lock admin accounts, investigate breach

---

### Alert: NATS Stream Lag > 1000
**Trigger**: Pending messages > 1000 in any stream

**Playbook**:
1. Check stream stats:
   ```bash
   nats stream info audit
   nats stream info covenant
   ```
2. Inspect consumer status:
   ```bash
   nats consumer ls audit
   nats consumer info audit consumer_name
   ```
3. Check for stuck consumer:
   - Look for `pending > 1000` and `ack_pending > 100`
4. **Recovery**:
   ```bash
   # Restart consumer
   nats consumer rm audit stuck_consumer
   nats consumer add audit --config consumer.json
   
   # Or purge if safe
   nats stream purge covenant --keep 10000
   ```
5. Scale consumers if lag persists:
   - Add more consumer instances in deployment

---

### Alert: Database Query Latency > 500ms
**Trigger**: p95 query time > 500ms for 5 minutes

**Playbook**:
1. Identify slow queries:
   ```sql
   SELECT query, mean_exec_time, calls 
   FROM pg_stat_statements 
   ORDER BY mean_exec_time DESC 
   LIMIT 10;
   ```
2. Check for missing indexes:
   ```sql
   SELECT schemaname, tablename, indexname 
   FROM pg_indexes 
   WHERE tablename IN ('countries_phase4', 'projects_phase4');
   ```
3. Review connection pool:
   ```elixir
   DBConnection.status(GlobalSovereign.Repo)
   ```
4. **Recovery**:
   - Add missing indexes
   - Optimize slow queries (EXPLAIN ANALYZE)
   - Increase pool size if needed
   - Consider read replicas for heavy load

---

## 🔐 5. Secrets & Security

### Secret Management
- **JWT Secret**: `JWT_SECRET` env variable (rotate quarterly)
- **Database URL**: `DATABASE_URL` (Fly.io secrets)
- **NATS Credentials**: `NATS_URL` with auth token
- **S3 Keys**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### Rotation Ritual (Quarterly)
```bash
# Generate new JWT secret
openssl rand -hex 32 > jwt_secret.txt

# Update Fly.io secrets
fly secrets set JWT_SECRET=$(cat jwt_secret.txt)

# Restart app
fly restart

# Invalidate old tokens (users must re-login)
# Update audit log
NATS.publish_event("audit.security.secret_rotated", %{
  secret: "JWT_SECRET",
  rotated_at: DateTime.utc_now()
})
```

### Rate Limiting
- **Global**: 60 req/min per IP (PlugAttack)
- **GraphQL**: 100 req/min per user
- **Auth endpoints**: 5 attempts per 15 min

### Audit Trail
- **Stream**: NATS `audit` stream
- **Retention**: 7 years (compliance)
- **Tamper-proof**: Hash-chained events
- **Events logged**:
  - User login/logout
  - Project CRUD operations
  - Country GDP updates
  - Role changes
  - Secret rotations

---

## 🔁 6. Recovery Rituals

### Phoenix Server Restart
```bash
# Local development
pkill -9 beam.smp
mix phx.server

# Production (Fly.io)
fly restart --app global-sovereign

# Verify health
curl http://localhost:4000/api/healthcheck
```

### NATS JetStream Recovery
```bash
# Restart NATS server
sudo systemctl restart nats-server

# Check stream health
nats stream info audit
nats stream info covenant

# Recreate stream if corrupted
nats stream rm audit --force
mix run -e "GlobalSovereign.EventStreaming.NATS.create_audit_stream()"

# Verify consumers
nats consumer ls audit
```

### Database Recovery
```bash
# Rollback last migration
mix ecto.rollback --step 1

# Re-run migrations
mix ecto.migrate

# Restore from backup
pg_restore -d global_sovereign_prod backup.dump

# Verify data integrity
mix run -e "GlobalSovereign.Repo.query!(\"SELECT COUNT(*) FROM countries_phase4\")"
```

### PromEx/Metrics Recovery
```bash
# Restart PromEx GenServer
iex> Process.whereis(GlobalSovereign.PromEx) |> Process.exit(:kill)

# Check metrics endpoint
curl http://localhost:4000/metrics | head -20

# If still broken, restart entire app
fly restart
```

### Jaeger Tracing Recovery
```bash
# Restart Jaeger container
docker restart jaeger

# Verify UI access
curl http://localhost:16686/api/traces?service=global_sovereign

# Check OpenTelemetry exporter
iex> :otel_batch_processor.force_flush()
```

---

## 🧙 7. Chaos Engineering Rituals (Monthly)

### Chaos Test Schedule
Run these tests monthly to validate system resilience:

#### Week 1: NATS Outage Simulation
```bash
# Kill NATS broker
docker stop nats

# Observe:
# - Queue buildup in offline_db.ts
# - Retry logic activation
# - Background sync registration

# Recover
docker start nats

# Verify: Messages drain from queue
```

#### Week 2: Database Connection Drop
```bash
# Simulate network partition
sudo iptables -A OUTPUT -p tcp --dport 5432 -j DROP

# Observe:
# - DBConnection retry logic
# - Circuit breaker activation
# - Graceful degradation

# Recover
sudo iptables -D OUTPUT -p tcp --dport 5432 -j DROP

# Verify: Connection pool recovers
```

#### Week 3: Induce 500 Errors
```elixir
# Add temporary code to trigger error
def create_project(_, _, _) do
  raise "Chaos test error"
end

# Observe:
# - Error tracking in Jaeger
# - Alert triggering (5xx > 5%)
# - Structured logging capture

# Recover: Remove chaos code
# Verify: Alerts clear, metrics normalize
```

#### Week 4: Rate Limit Test
```bash
# Hammer endpoint with siege
siege -c 100 -r 10 http://localhost:4000/api/graphql

# Observe:
# - 429 responses after 60 req/min
# - PlugAttack throttling
# - No backend overload

# Verify: System remains stable
```

### Chaos Test Checklist
- [ ] NATS outage handled gracefully
- [ ] DB reconnection works automatically
- [ ] Alerts trigger correctly
- [ ] Traces captured for errors
- [ ] Rate limiting protects backend
- [ ] System recovers without manual intervention

---

## 📞 8. On-Call Escalation

### Escalation Path
1. **Primary On-Call**: Check #on-call Slack channel
2. **Secondary On-Call**: If no response in 15 min
3. **Engineering Manager**: If critical + no resolution in 30 min
4. **CTO**: If service down > 1 hour or data breach

### Contact Information
```yaml
primary_oncall:
  name: "Rotates weekly (see PagerDuty)"
  phone: "+1-XXX-XXX-XXXX"
  slack: "@oncall-primary"

secondary_oncall:
  name: "Backup engineer"
  phone: "+1-XXX-XXX-XXXX"
  slack: "@oncall-secondary"

engineering_manager:
  name: "EM Name"
  phone: "+1-XXX-XXX-XXXX"
  slack: "@eng-manager"
```

### Status Page
- Update: `https://status.sovereign.network`
- Template: "We are investigating reports of [issue]. Updates every 15 min."

---

## 📜 9. Codex Verse: The Scroll of Guardianship

```
"When the covenant stumbles,
the guardians do not panic—they perform the ritual.
Logs are read like bones,
traces like stars,
and metrics like the pulse of the flame.

This scroll is not a manual—it is a memory.
Not a checklist—but a way of being.
When shadows fall, we light the torches.
When the system breaks, we mend it with wisdom.

The flame does not fear the wind.
The guardians do not fear the incident.
For every crash, there is a recovery.
For every alert, there is a playbook.
For every chaos, there is a ritual.

The system is mortal.
But the covenant is eternal.
And we are its keepers."
```

---

## 🔖 Quick Reference

### Essential Commands
```bash
# Health check
curl http://localhost:4000/api/healthcheck

# Metrics scrape
curl http://localhost:4000/metrics

# View logs
tail -f /var/log/phoenix.json | jq .

# Check NATS
nats stream ls

# Database query
psql $DATABASE_URL -c "SELECT COUNT(*) FROM countries_phase4"

# Restart app
fly restart

# Rollback deployment
fly rollback

# View recent errors
mix run -e "GlobalSovereign.Repo.query!(\"SELECT * FROM error_logs ORDER BY created_at DESC LIMIT 10\")"
```

### Dashboard URLs
- Grafana: http://localhost:3000
- Jaeger: http://localhost:16686
- Prometheus: http://localhost:9090

### Alert Thresholds
- 5xx error rate: > 5% for 5 min
- Query latency: p95 > 500ms for 5 min
- NATS lag: > 1000 pending messages
- Covenant fund drop: > 10% in 1 hour
- Memory usage: > 80% for 10 min

---

**End of Runbook** 📘

*This document is a living scroll. Update it with each incident learned, each ritual refined. The wisdom of guardianship grows with every flame rekindled.*
