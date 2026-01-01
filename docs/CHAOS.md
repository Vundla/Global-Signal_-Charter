# Chaos Engineering: "Crash It If You Can"

## Philosophy

> *"Chaos is the teacher. Recovery is the testament."*

Chaos engineering validates that our fault-tolerant architecture can withstand real-world failures. We intentionally inject faults to discover weaknesses before they cause outages.

---

## Chaos Principles

1. **Hypothesize steady state**: Define normal system behavior
2. **Vary real-world events**: Inject realistic failures
3. **Run experiments in production**: Test where it matters
4. **Automate experiments**: Make chaos continuous
5. **Minimize blast radius**: Start small, expand gradually

---

## Fault Injection Scenarios

### Network Chaos

#### Latency Injection

```elixir
defmodule GlobalSovereign.Chaos.NetworkLatency do
  @moduledoc """
  Injects latency into network requests to simulate degraded connectivity.
  """
  
  def inject_latency(min_ms, max_ms) do
    delay_ms = Enum.random(min_ms..max_ms)
    Process.sleep(delay_ms)
  end
  
  def with_latency(func, min_ms \\ 100, max_ms \\ 1000) do
    inject_latency(min_ms, max_ms)
    func.()
  end
end

# Usage
GlobalSovereign.Chaos.NetworkLatency.with_latency(fn ->
  HTTPoison.get("https://api.example.com/data")
end)
```

#### Packet Loss Simulation

```elixir
defmodule GlobalSovereign.Chaos.PacketLoss do
  @moduledoc """
  Simulates packet loss by randomly failing requests.
  """
  
  def with_packet_loss(func, loss_rate \\ 0.1) do
    if :rand.uniform() < loss_rate do
      {:error, :network_unreachable}
    else
      func.()
    end
  end
end
```

#### Link Failure

```bash
# Simulate complete link failure
sudo tc qdisc add dev eth0 root netem loss 100%

# Restore
sudo tc qdisc del dev eth0 root
```

### Process Chaos

#### Random Process Kills

```elixir
defmodule GlobalSovereign.Chaos.ProcessKiller do
  @moduledoc """
  Randomly kills processes to test supervision tree recovery.
  """
  use GenServer
  require Logger

  @kill_interval :timer.minutes(5)
  @kill_probability 0.1

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    if Application.get_env(:global_sovereign, :chaos_enabled, false) do
      schedule_chaos()
    end
    {:ok, %{}}
  end

  @impl true
  def handle_info(:chaos_strike, state) do
    if :rand.uniform() < @kill_probability do
      kill_random_worker()
    end
    
    schedule_chaos()
    {:noreply, state}
  end

  defp schedule_chaos do
    Process.send_after(self(), :chaos_strike, @kill_interval)
  end

  defp kill_random_worker do
    workers = [
      GlobalSovereign.Sync.PriorityScheduler,
      GlobalSovereign.CacheWarmer.Worker
    ]
    
    target = Enum.random(workers)
    
    case Process.whereis(target) do
      nil -> 
        Logger.debug("[Chaos] Worker #{inspect(target)} not running")
      
      pid ->
        Logger.warning("[Chaos] Killing worker #{inspect(target)} (#{inspect(pid)})")
        Process.exit(pid, :kill)
    end
  end
end
```

### Database Chaos

#### Connection Drops

```elixir
defmodule GlobalSovereign.Chaos.DatabaseFailure do
  def with_db_failure(func, failure_rate \\ 0.05) do
    if :rand.uniform() < failure_rate do
      {:error, :database_connection_failed}
    else
      func.()
    end
  end
end
```

#### Slow Queries

```elixir
defmodule GlobalSovereign.Chaos.SlowQuery do
  def inject_query_delay(min_ms \\ 500, max_ms \\ 5000) do
    delay = Enum.random(min_ms..max_ms)
    Logger.warning("[Chaos] Injecting query delay: #{delay}ms")
    Process.sleep(delay)
  end
end
```

### Power Chaos

#### Battery Drain Simulation

```elixir
defmodule GlobalSovereign.Chaos.PowerFailure do
  @moduledoc """
  Simulates battery drain to test power-aware service shedding.
  """
  
  def simulate_battery_drain do
    # Gradually reduce battery percentage
    Enum.reduce(100..10, fn battery, _acc ->
      GlobalSovereign.Power.Manager.set_battery_level(battery)
      Logger.info("[Chaos] Battery level: #{battery}%")
      Process.sleep(:timer.seconds(30))
      battery
    end
  end
  
  def simulate_power_outage do
    Logger.warning("[Chaos] Simulating power outage")
    GlobalSovereign.Power.Manager.set_battery_level(5)
  end
end
```

---

## Game Day Procedures

### Pre-Game Day Checklist

- [ ] Announce game day window to all stakeholders
- [ ] Ensure all monitoring and alerting is operational
- [ ] Prepare rollback procedures
- [ ] Brief on-call engineers
- [ ] Set up war room (Slack/Zoom channel)
- [ ] Document baseline metrics

### Game Day Scenario 1: Link Failover

**Hypothesis**: System gracefully degrades from fibre to LTE when primary link fails.

**Procedure**:
```bash
# 1. Establish baseline
curl https://api.sovereign.network/health

# 2. Inject failure (disconnect fibre)
sudo tc qdisc add dev eth0 root netem loss 100%

# 3. Observe metrics
# - Link health monitor should detect failure
# - Traffic should route to LTE interface
# - Sync priority should adjust (only P0, P1)

# 4. Verify recovery
sudo tc qdisc del dev eth0 root

# 5. Confirm normal operations
curl https://api.sovereign.network/health
```

**Success Criteria**:
- Failover to LTE within 30 seconds
- No user-facing errors
- Sync continues with adjusted priorities
- Automatic recovery when fibre restores

### Game Day Scenario 2: Database Replica Failure

**Hypothesis**: System continues operating when one database replica fails.

**Procedure**:
```bash
# 1. Identify replicas
fly postgres db list

# 2. Kill one replica
fly postgres db destroy replica-02

# 3. Observe
# - Postgres should promote another standby
# - Read queries should route to remaining replicas
# - No write failures

# 4. Restore replica
fly postgres db create replica-02

# 5. Verify replication sync
fly postgres db check
```

**Success Criteria**:
- No write failures during replica failure
- Read queries auto-route to healthy replicas
- Replication catches up within 5 minutes

### Game Day Scenario 3: Cascading Worker Failures

**Hypothesis**: Supervision tree recovers from multiple worker crashes.

**Procedure**:
```elixir
# In IEx console
# 1. Enable chaos mode
Application.put_env(:global_sovereign, :chaos_enabled, true)

# 2. Restart chaos killer
GlobalSovereign.Chaos.ProcessKiller.start_link([])

# 3. Monitor supervisor restarts
:observer.start()

# 4. Observe recovery
# Workers should restart automatically
# Circuit breakers should open for failing dependencies
# System should maintain core functionality

# 5. Disable chaos
Application.put_env(:global_sovereign, :chaos_enabled, false)
```

**Success Criteria**:
- Workers restart within 5 seconds
- No more than 10 restarts per minute (backoff working)
- User-facing services remain available
- Circuit breakers prevent cascading failures

### Game Day Scenario 4: Cache Poisoning

**Hypothesis**: System detects and rejects corrupted cached content.

**Procedure**:
```elixir
# 1. Inject bad content into cache
Cachex.put(:sovereign_cache, "content:education:abc123", 
  "corrupted data", ttl: :timer.hours(1))

# 2. Attempt to retrieve
case Cachex.get(:sovereign_cache, "content:education:abc123") do
  {:ok, content} ->
    # Verify hash
    GlobalSovereign.Sync.ContentVerifier.verify(content, item)
end

# 3. Observe
# Content verifier should reject corrupted data
# System should fetch fresh copy from origin
# Audit log should record integrity violation
```

**Success Criteria**:
- Corrupted content rejected by verifier
- Fresh content fetched from IPFS/origin
- Audit log entry created
- Alert sent to operations team

---

## Chaos Metrics

### Key Performance Indicators (KPIs)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Mean Time to Detect (MTTD) | <30 seconds | From fault injection to alert |
| Mean Time to Recover (MTTR) | <5 minutes | From alert to full recovery |
| Error Budget | <0.1% | Percentage of failed requests |
| Cache Hit Ratio | >80% | During degraded connectivity |
| Supervisor Restart Rate | <10/minute | Process recovery speed |

### Monitoring During Chaos

```elixir
defmodule GlobalSovereign.Chaos.Metrics do
  use PromEx.Plugin

  @impl true
  def event_metrics do
    [
      distribution(
        "chaos.recovery_time_seconds",
        event_name: [:chaos, :recovery],
        measurement: :duration,
        description: "Time to recover from chaos event",
        unit: {:native, :second},
        tags: [:chaos_type, :severity]
      ),
      
      counter(
        "chaos.failures_total",
        event_name: [:chaos, :failure],
        description: "Total chaos-induced failures",
        tags: [:chaos_type, :component]
      )
    ]
  end
end
```

---

## Automated Chaos Testing

### Continuous Chaos with ChaosMonkey

```elixir
defmodule GlobalSovereign.ChaosMonkey do
  use GenServer
  require Logger

  @chaos_schedule [
    {GlobalSovereign.Chaos.NetworkLatency, :inject_latency, [100, 500], :timer.minutes(15)},
    {GlobalSovereign.Chaos.ProcessKiller, :kill_random_worker, [], :timer.minutes(30)},
    {GlobalSovereign.Chaos.PacketLoss, :with_packet_loss, [0.05], :timer.minutes(20)}
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    if chaos_enabled?() do
      schedule_chaos_events()
    end
    {:ok, %{}}
  end

  defp chaos_enabled? do
    Application.get_env(:global_sovereign, :continuous_chaos, false) and
      System.get_env("MIX_ENV") != "prod"
  end

  defp schedule_chaos_events do
    Enum.each(@chaos_schedule, fn {module, func, args, interval} ->
      Process.send_after(self(), {:chaos, module, func, args, interval}, interval)
    end)
  end

  @impl true
  def handle_info({:chaos, module, func, args, interval}, state) do
    Logger.info("[ChaosMonkey] Executing #{module}.#{func}")
    
    try do
      apply(module, func, args)
    rescue
      error ->
        Logger.error("[ChaosMonkey] Chaos failed: #{inspect(error)}")
    end
    
    Process.send_after(self(), {:chaos, module, func, args, interval}, interval)
    {:noreply, state}
  end
end
```

### CI/CD Integration

```yaml
# .github/workflows/chaos-test.yml
name: Chaos Testing

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  chaos-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17'
          otp-version: '26.2'
      
      - name: Install dependencies
        run: mix deps.get
      
      - name: Run chaos tests
        run: |
          export CHAOS_ENABLED=true
          mix test --only chaos
      
      - name: Upload chaos report
        uses: actions/upload-artifact@v3
        with:
          name: chaos-report
          path: chaos-report.html
```

---

## Chaos Test Suite

```elixir
defmodule GlobalSovereign.ChaosTest do
  use ExUnit.Case, async: false
  
  @moduletag :chaos

  describe "network chaos" do
    test "system handles latency spikes" do
      # Inject 500ms-2s latency
      GlobalSovereign.Chaos.NetworkLatency.with_latency(fn ->
        assert {:ok, _} = GlobalSovereign.Sync.fetch_content("education", "test.pdf")
      end, 500, 2000)
    end

    test "system recovers from packet loss" do
      results = 
        Enum.map(1..100, fn _ ->
          GlobalSovereign.Chaos.PacketLoss.with_packet_loss(fn ->
            HTTPoison.get("http://localhost:4000/health")
          end, 0.2)
        end)
      
      # Should have some failures but eventual success via retries
      successes = Enum.count(results, &match?({:ok, _}, &1))
      assert successes > 50
    end
  end

  describe "process chaos" do
    test "supervisor restarts crashed workers" do
      worker_pid = Process.whereis(GlobalSovereign.Sync.PriorityScheduler)
      assert is_pid(worker_pid)
      
      # Kill the worker
      Process.exit(worker_pid, :kill)
      
      # Wait for supervisor to restart
      Process.sleep(100)
      
      # Verify new process started
      new_pid = Process.whereis(GlobalSovereign.Sync.PriorityScheduler)
      assert is_pid(new_pid)
      assert new_pid != worker_pid
    end
  end

  describe "database chaos" do
    test "system handles query timeouts" do
      # This would require test-specific database configuration
      # to simulate timeouts
      
      assert {:error, :timeout} = 
        GlobalSovereign.Repo.query("SELECT pg_sleep(10)", [], timeout: 100)
    end
  end
end
```

---

## Chaos Calendar

### Weekly Chaos Schedule

| Day | Chaos Type | Duration | Blast Radius |
|-----|-----------|----------|--------------|
| Monday | Network latency | 1 hour | Dev environment |
| Tuesday | Process kills | 30 minutes | Staging |
| Wednesday | Database replica failure | 2 hours | Staging |
| Thursday | Cache poisoning | 1 hour | Dev environment |
| Friday | **Game Day** | 3 hours | Production (controlled) |

### Quarterly Game Days

- **Q1**: Full region failover (Johannesburg → Frankfurt)
- **Q2**: Complete power outage simulation
- **Q3**: Multi-component cascading failure
- **Q4**: Security breach simulation

---

## Lessons Learned Archive

### Template

```markdown
## Chaos Event: [Title]
**Date**: YYYY-MM-DD
**Duration**: X hours
**Severity**: P0/P1/P2/P3

### Hypothesis
What we expected to happen.

### Actual Behavior
What actually happened.

### Impact
- User-facing impact: X users affected
- Duration: Y minutes
- Services affected: [list]

### Root Cause
Why did the system behave this way?

### Improvements
- [ ] Action item 1
- [ ] Action item 2
- [ ] Action item 3

### Codex Inscription
*Verse added to commemorate the lesson learned.*
```

---

## Chaos Commands Reference

```bash
# Enable continuous chaos (dev/staging only)
export CHAOS_ENABLED=true
mix phx.server

# Run chaos test suite
mix test --only chaos

# Game day simulation
mix chaos.game_day --scenario=link_failover

# Network chaos
sudo tc qdisc add dev eth0 root netem delay 200ms 50ms
sudo tc qdisc add dev eth0 root netem loss 10%
sudo tc qdisc del dev eth0 root

# Process chaos
iex> GlobalSovereign.Chaos.ProcessKiller.kill_random_worker()

# Power chaos
iex> GlobalSovereign.Chaos.PowerFailure.simulate_battery_drain()
```

---

## Philosophy Reminder

> *"We do not fear chaos—we embrace it as the ultimate teacher. Every crash, every failure, every recovery makes us more resilient. This is the covenant of fault tolerance: we crash, we learn, we survive."*

**Guarded by the Leopard, Lion, and Hare**

---

Next: [Frontend Implementation](./FRONTEND.md)
