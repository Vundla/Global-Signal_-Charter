# 🚀 NATS JetStream Event Streaming Configuration

**Status**: ✅ Phase 4 Tier 1 Infrastructure  
**Deployment**: 3-node HA cluster across regions  
**Target Go-Live**: February 2026  

---

## 📊 Architecture Overview

### Cluster Topology

```
┌─────────────────────────────────────────────────────────────┐
│                 NATS JetStream Cluster                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Primary]              [Secondary]          [Tertiary]    │
│  nats-1 (iad)          nats-2 (ams)         nats-3 (syd)  │
│  ✓ KV Store            ✓ Object Store       ✓ Metadata     │
│  ✓ Leader              ✓ Replication        ✓ Replication  │
│                                                             │
│  Quorum: 3/3 (100% HA)                                     │
│  Retention: Persistent (JetStream Streams)                 │
│  Replication Factor: 3 (all nodes)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
     ↓                    ↓                    ↓
  IAD Broker          AMS Broker          SYD Broker
  Region Primary      Region Replica      Region Replica
```

### Stream Architecture

```
                        Publishers
                             │
                    ┌────────┼────────┐
                    ↓        ↓        ↓
                 Country   Project  User
                 Events    Events   Events
                    │        │        │
    ┌───────────────┴────────┴────────┴────────────────┐
    │                                                  │
    ↓ JetStream Streams (Persistent)                  │
    ├── covenant.countries.>                          │
    ├── covenant.projects.>                           │
    ├── covenant.users.>                              │
    └── alerts.incidents.>                            │
    │                                                  │
    ↓ Consumers (Replicated)                          │
    ├── [Analytics] → PostgreSQL                      │
    ├── [Cache Invalidator] → Redis                   │
    ├── [Notification] → Push Service                 │
    └── [Audit Logger] → Audit Trail                  │
    │                                                  │
    ↓ Subscribers (Regional Deployments)              │
    ├── GraphQL API (IAD, AMS, SYD, SIN, SFO, JNB)   │
    ├── Mobile Apps (iOS, Android)                    │
    └── Frontend Clients (Web)                        │
```

---

## 🔧 Configuration Files

### 1. NATS Server Config (nats-server.conf)

```nats
# NATS Server Configuration for Global Sovereign Network

# Cluster Configuration
cluster {
  name: "global-sovereign"
  listen: 0.0.0.0:6222
  
  # Cluster peer connections
  routes: [
    nats://nats-2.nats.svc.cluster.local:6222
    nats://nats-3.nats.svc.cluster.local:6222
  ]
  
  # Cluster routing protocol
  cluster_advertise: $CLUSTER_ADVERTISE
  
  # Compression and security
  compression: s2
  tls {
    cert_file: /etc/nats/tls/server.crt
    key_file: /etc/nats/tls/server.key
    ca_file: /etc/nats/tls/ca.crt
  }
}

# Listen ports
listen: 0.0.0.0:4222
port: 4222

# HTTP monitoring
http: 8222
https: 8223

# Authentication & Authorization
authorization {
  users: [
    {
      user: "api"
      password: $API_PASSWORD
      permissions {
        publish: {
          allow: ["covenant.>", "alerts.>"]
        }
        subscribe: {
          allow: ["covenant.>", "alerts.>", "_INBOX.>"]
        }
      }
    }
    {
      user: "mobile"
      password: $MOBILE_PASSWORD
      permissions {
        publish: {
          allow: ["user-events.>"]
        }
        subscribe: {
          allow: ["covenant.>", "alerts.>"]
        }
      }
    }
    {
      user: "analytics"
      password: $ANALYTICS_PASSWORD
      permissions {
        subscribe: {
          allow: ["covenant.>", "alerts.>"]
        }
        publish: null
      }
    }
  ]
  
  default_user: "api"
  default_permissions {
    publish: null
    subscribe: null
  }
}

# JetStream Configuration
jetstream {
  store_dir: /data/jetstream
  max_memory_store: 2GB
  max_file_store: 100GB
  
  # Domain for multi-cluster deployments
  domain: global
}

# Logging
logging {
  debug: false
  trace: false
  colors: true
  time_format: "2006-01-02 15:04:05.000 -0700"
}

# Server limits
max_connections: 65536
max_control_line: 4096
max_payload: 8388608

# Performance tuning
lame_duck_duration: 30s
lame_duck_grace_period: 10s

# System accounts
system_account: $SYS
```

### 2. Kubernetes StatefulSet (k8s-nats.yaml)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nats

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nats-config
  namespace: nats
data:
  nats-server.conf: |
    # (See above configuration)

---
apiVersion: v1
kind: Service
metadata:
  name: nats
  namespace: nats
  labels:
    app: nats
spec:
  clusterIP: None
  selector:
    app: nats
  ports:
    - name: client
      port: 4222
      targetPort: 4222
    - name: cluster
      port: 6222
      targetPort: 6222
    - name: http
      port: 8222
      targetPort: 8222

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nats
  namespace: nats
spec:
  serviceName: nats
  replicas: 3
  selector:
    matchLabels:
      app: nats
  template:
    metadata:
      labels:
        app: nats
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values: [nats]
              topologyKey: kubernetes.io/hostname
      
      terminationGracePeriodSeconds: 60
      
      containers:
        - name: nats
          image: nats:2.10.0-alpine
          imagePullPolicy: IfNotPresent
          
          # Resource limits
          resources:
            requests:
              cpu: 500m
              memory: 512Mi
            limits:
              cpu: 2
              memory: 2Gi
          
          # Ports
          ports:
            - containerPort: 4222
              name: client
            - containerPort: 6222
              name: cluster
            - containerPort: 8222
              name: http
          
          # Environment variables
          env:
            - name: CLUSTER_ADVERTISE
              value: "$(POD_NAME).nats.nats.svc.cluster.local"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
          
          # Config volume mount
          volumeMounts:
            - name: config
              mountPath: /etc/nats
            - name: data
              mountPath: /data
          
          # Readiness/Liveness probes
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8222
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
          
          livenessProbe:
            httpGet:
              path: /healthz?js
              port: 8222
            initialDelaySeconds: 15
            periodSeconds: 20
            timeoutSeconds: 5
      
      # Volumes
      volumes:
        - name: config
          configMap:
            name: nats-config
      
      # Persistent storage
      volumeClaimTemplates:
        - metadata:
            name: data
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 100Gi

---
apiVersion: v1
kind: Service
metadata:
  name: nats-lb
  namespace: nats
  labels:
    app: nats
spec:
  type: LoadBalancer
  selector:
    app: nats
  ports:
    - name: client
      port: 4222
      targetPort: 4222
    - name: http
      port: 8222
      targetPort: 8222
```

### 3. Docker Compose (Local Development)

```yaml
version: '3.8'

services:
  nats-1:
    image: nats:2.10.0-alpine
    hostname: nats-1
    ports:
      - "4222:4222"
      - "6222:6222"
      - "8222:8222"
    command: >
      -c /etc/nats/nats-server.conf
      --cluster_advertise nats-1:6222
    volumes:
      - ./nats-server.conf:/etc/nats/nats-server.conf
      - nats-1-data:/data
    networks:
      - nats

  nats-2:
    image: nats:2.10.0-alpine
    hostname: nats-2
    ports:
      - "4223:4222"
      - "6223:6222"
      - "8223:8222"
    command: >
      -c /etc/nats/nats-server.conf
      --cluster_advertise nats-2:6222
      --routes nats://nats-1:6222
    volumes:
      - ./nats-server.conf:/etc/nats/nats-server.conf
      - nats-2-data:/data
    depends_on:
      - nats-1
    networks:
      - nats

  nats-3:
    image: nats:2.10.0-alpine
    hostname: nats-3
    ports:
      - "4224:4222"
      - "6224:6222"
      - "8224:8222"
    command: >
      -c /etc/nats/nats-server.conf
      --cluster_advertise nats-3:6222
      --routes nats://nats-1:6222
    volumes:
      - ./nats-server.conf:/etc/nats/nats-server.conf
      - nats-3-data:/data
    depends_on:
      - nats-1
    networks:
      - nats

volumes:
  nats-1-data:
  nats-2-data:
  nats-3-data:

networks:
  nats:
    driver: bridge
```

---

## 📋 Stream & Consumer Configuration

### Covenant Streams

```typescript
// Stream: covenant.countries.>
{
  name: "COVENANT_COUNTRIES",
  subjects: ["covenant.countries.created", "covenant.countries.updated", "covenant.countries.deleted"],
  retention: "interest",  // Keep until consumed
  maxAge: 2592000000,     // 30 days
  maxMsgs: 1000000,
  discard: "old",
  replicas: 3,            // HA replication
  encryption: {
    algorithm: "AES",
    key: "..." // Secret key
  }
}

// Stream: covenant.projects.>
{
  name: "COVENANT_PROJECTS",
  subjects: ["covenant.projects.created", "covenant.projects.updated", "covenant.projects.deleted"],
  retention: "interest",
  maxAge: 2592000000,
  maxMsgs: 1000000,
  discard: "old",
  replicas: 3,
  encryption: { algorithm: "AES", key: "..." }
}

// Stream: covenant.users.>
{
  name: "COVENANT_USERS",
  subjects: ["covenant.users.created", "covenant.users.updated", "covenant.users.deleted"],
  retention: "interest",
  maxAge: 604800000,  // 7 days
  maxMsgs: 100000,
  discard: "old",
  replicas: 3,
  encryption: { algorithm: "AES", key: "..." }
}

// Stream: alerts.incidents.>
{
  name: "ALERTS_INCIDENTS",
  subjects: ["alerts.incidents.critical", "alerts.incidents.warning", "alerts.incidents.info"],
  retention: "limits",
  maxAge: 86400000,   // 1 day
  maxMsgs: 10000,
  discard: "new",
  replicas: 3,
  encryption: { algorithm: "AES", key: "..." }
}
```

### Consumers (Pull/Push)

```typescript
// Analytics Consumer (Pull)
{
  durable_name: "ANALYTICS",
  flow_control: { idle_heartbeat: 5000, max_ack_pending: 100 },
  max_deliver: 20,
  backoff: [1000, 5000, 10000, 30000],
  filter_subject: "covenant.>",
  deliver_policy: "all",
}

// Cache Invalidator (Push)
{
  durable_name: "CACHE_INVALIDATOR",
  deliver_subject: "consumer.cache-invalidator",
  flow_control: { idle_heartbeat: 5000, max_ack_pending: 100 },
  filter_subject: "covenant.>",
  deliver_policy: "new",
  rate_limit_bps: 1000000,
}

// Notification Service (Push)
{
  durable_name: "NOTIFICATIONS",
  deliver_subject: "consumer.notifications",
  flow_control: { idle_heartbeat: 5000 },
  filter_subject: "alerts.>",
  deliver_policy: "new",
}

// Audit Logger (Pull)
{
  durable_name: "AUDIT_LOGGER",
  flow_control: { idle_heartbeat: 60000, max_ack_pending: 1000 },
  filter_subject: ["covenant.>", "alerts.>"],
  deliver_policy: "all",
  replay_policy: "original",
}
```

---

## 🚀 Deployment Instructions

### Phase 1: Local Testing

```bash
# Start NATS cluster locally
docker-compose up -d

# Check cluster status
nats server ls

# Create streams
./scripts/create-streams.sh

# Test publishing
nats pub covenant.countries.created '{"code":"USA","name":"United States"}'

# Test consuming
nats sub covenant.countries.>
```

### Phase 2: Kubernetes Deployment

```bash
# Create namespace and secrets
kubectl create namespace nats
kubectl create secret generic nats-auth \
  --from-literal=api-password=$API_PASSWORD \
  --from-literal=mobile-password=$MOBILE_PASSWORD \
  -n nats

# Deploy NATS cluster
kubectl apply -f k8s/nats-statefulset.yaml

# Verify deployment
kubectl get pods -n nats
kubectl logs -f nats-0 -n nats

# Create streams and consumers
kubectl exec -it nats-0 -n nats -- \
  nats stream create COVENANT_COUNTRIES ...
```

### Phase 3: Multi-Region Deployment

```bash
# Deploy to each region
for region in ams iad syd sin sfo jnb; do
  kubectl apply -f k8s/nats-$region.yaml
done

# Configure gateways for inter-region communication
kubectl apply -f k8s/nats-gateways.yaml

# Verify cluster peering
nats server report
```

---

## 📊 Monitoring & Observability

### Prometheus Metrics

```yaml
scrape_configs:
  - job_name: 'nats-jetstream'
    static_configs:
      - targets:
        - 'nats-1:8222'
        - 'nats-2:8222'
        - 'nats-3:8222'
```

### Key Metrics

- `nats_jetstream_streams`: Number of streams
- `nats_jetstream_consumers`: Number of consumers
- `nats_jetstream_messages`: Messages in streams
- `nats_jetstream_bytes`: Bytes in streams
- `nats_routes_inbound`: Cluster route connections
- `nats_routes_outbound`: Cluster route connections

### Dashboard

```
Grafana Dashboard: NATS JetStream Monitoring
├── Cluster Health
│   ├── Node Status (3/3 up)
│   ├── Cluster Routes (connected)
│   └── Server Uptime
├── Stream Metrics
│   ├── Total Messages (growing)
│   ├── Message Rate (msg/sec)
│   └── Bytes Per Stream
├── Consumer Metrics
│   ├── Pending Messages (queue depth)
│   ├── Processing Rate
│   └── Error Rate
└── Performance
    ├── Publish Latency (p50, p95, p99)
    ├── Subscribe Latency
    └── Replication Lag
```

---

## ✅ Phase 1 Checklist

- [ ] NATS cluster deployed (3 nodes)
- [ ] JetStream enabled on all nodes
- [ ] Streams created (covenant.*, alerts.*)
- [ ] Consumers configured
- [ ] Authentication enabled
- [ ] TLS certificates generated
- [ ] Kubernetes StatefulSet validated
- [ ] Docker Compose tested locally
- [ ] Monitoring dashboards created
- [ ] Load testing completed
- [ ] Failover tested
- [ ] Backup strategy documented

---

## 📈 Expected Performance

| Metric | Target | Notes |
|--------|--------|-------|
| Publish Latency (p99) | < 50ms | Single region |
| Subscribe Latency | < 10ms | Local delivery |
| Throughput | > 100k msg/sec | Per cluster |
| Replication Lag | < 100ms | Cross-region |
| Availability | 99.99% | HA cluster |

---

## 🔗 Related Documentation

- [Architecture](../docs/ARCHITECTURE.md)
- [Deployment Guide](../terraform/DEPLOYMENT_GUIDE.md)
- [Phase 4 Plan](../PHASE4_PLAN.md)
- [Go-Live Checklist](../GO_LIVE_CHECKLIST.md)

---

**Status**: ✅ Configuration complete  
**Next Step**: Deploy locally with Docker Compose  
**Timeline**: 2 weeks for full setup  
**Owner**: Platform/Infrastructure Team
