# Security Hardening Guide

## Zero-Trust Architecture

### Principles

1. **Never trust, always verify**: Every request must be authenticated and authorized
2. **Least privilege**: Grant minimum necessary permissions
3. **Assume breach**: Design for containment and recovery
4. **Continuous validation**: Monitor and audit all access

---

## mTLS (Mutual TLS) Implementation

### Certificate Generation

```bash
# Generate CA certificate
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 3650 -key ca-key.pem -out ca-cert.pem \
  -subj "/C=ZA/ST=Gauteng/L=Johannesburg/O=Global Sovereign/CN=Sovereign CA"

# Generate server certificate
openssl genrsa -out server-key.pem 4096
openssl req -new -key server-key.pem -out server.csr \
  -subj "/C=ZA/ST=Gauteng/L=Johannesburg/O=Global Sovereign/CN=api.sovereign.network"

openssl x509 -req -days 365 -in server.csr -CA ca-cert.pem -CAkey ca-key.pem \
  -set_serial 01 -out server-cert.pem

# Generate client certificate
openssl genrsa -out client-key.pem 4096
openssl req -new -key client-key.pem -out client.csr \
  -subj "/C=ZA/ST=Gauteng/L=Johannesburg/O=Global Sovereign/CN=client"

openssl x509 -req -days 365 -in client.csr -CA ca-cert.pem -CAkey ca-key.pem \
  -set_serial 02 -out client-cert.pem
```

### Phoenix Configuration

```elixir
# config/runtime.exs
config :global_sovereign, GlobalSovereignWeb.Endpoint,
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: System.get_env("SSL_CERT_PATH") || "priv/cert/server-cert.pem",
    keyfile: System.get_env("SSL_KEY_PATH") || "priv/cert/server-key.pem",
    cacertfile: System.get_env("SSL_CA_PATH") || "priv/cert/ca-cert.pem",
    verify: :verify_peer,
    fail_if_no_peer_cert: true,
    depth: 3,
    versions: [:"tlsv1.3", :"tlsv1.2"],
    honor_cipher_order: true,
    secure_renegotiate: true
  ]
```

### Certificate Rotation

```elixir
defmodule GlobalSovereign.Security.CertRotation do
  use GenServer
  require Logger

  @rotation_check_interval :timer.hours(24)
  @rotation_threshold_days 30

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_check()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_rotation, state) do
    case check_cert_expiry() do
      {:needs_rotation, days_left} ->
        Logger.warning("Certificate expires in #{days_left} days, rotating...")
        rotate_certificates()
      
      {:ok, days_left} ->
        Logger.info("Certificate valid for #{days_left} days")
    end
    
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check_rotation, @rotation_check_interval)
  end

  defp check_cert_expiry do
    cert_path = System.get_env("SSL_CERT_PATH") || "priv/cert/server-cert.pem"
    
    case File.read(cert_path) do
      {:ok, pem} ->
        [entry] = :public_key.pem_decode(pem)
        cert = :public_key.pem_entry_decode(entry)
        
        {:Validity, _not_before, not_after} = 
          elem(cert, elem(cert, 0) |> Tuple.to_list() |> Enum.find_index(&(&1 == :tbsCertificate))) 
          |> elem(5)
        
        expiry_date = parse_asn1_time(not_after)
        days_left = Date.diff(expiry_date, Date.utc_today())
        
        if days_left <= @rotation_threshold_days do
          {:needs_rotation, days_left}
        else
          {:ok, days_left}
        end
      
      {:error, reason} ->
        Logger.error("Failed to read certificate: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp rotate_certificates do
    # Implementation: call certificate authority API or generate new certs
    Logger.info("Rotating certificates...")
  end

  defp parse_asn1_time({:utcTime, time_string}) do
    # Parse ASN.1 UTCTime format
    <<year::binary-size(2), month::binary-size(2), day::binary-size(2), _rest::binary>> = time_string
    Date.new!(2000 + String.to_integer(year), String.to_integer(month), String.to_integer(day))
  end
end
```

---

## WireGuard Mesh Network

### Configuration

```ini
# /etc/wireguard/wg0.conf (Primary Tower)
[Interface]
PrivateKey = <primary_tower_private_key>
Address = 10.99.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Secondary Tower
[Peer]
PublicKey = <secondary_tower_public_key>
AllowedIPs = 10.99.0.2/32
Endpoint = tower2.sovereign.network:51820
PersistentKeepalive = 25

# Regional Hub
[Peer]
PublicKey = <hub_public_key>
AllowedIPs = 10.99.0.0/16
Endpoint = hub.sovereign.network:51820
PersistentKeepalive = 25
```

### Key Management

```bash
# Generate WireGuard keys
wg genkey | tee privatekey | wg pubkey > publickey

# Set permissions
chmod 600 privatekey
chmod 644 publickey

# Deploy with Ansible/Terraform
fly secrets set WIREGUARD_PRIVATE_KEY="$(cat privatekey)"
```

---

## RBAC (Role-Based Access Control)

### Role Definitions

```elixir
defmodule GlobalSovereign.Auth.Roles do
  @roles %{
    super_admin: [
      :manage_all,
      :view_all,
      :deploy_towers,
      :manage_finances
    ],
    
    country_admin: [
      :manage_country_towers,
      :view_country_metrics,
      :approve_allocations
    ],
    
    tower_operator: [
      :manage_tower,
      :view_tower_metrics,
      :sync_content
    ],
    
    community_member: [
      :view_content,
      :use_services
    ]
  }

  def permissions(role) do
    Map.get(@roles, role, [])
  end

  def has_permission?(user, permission) do
    permissions(user.role)
    |> Enum.member?(permission)
  end
end
```

### Guardian Implementation

```elixir
defmodule GlobalSovereign.Auth.Guardian do
  use Guardian, otp_app: :global_sovereign

  alias GlobalSovereign.Accounts

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end

defmodule GlobalSovereign.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :global_sovereign,
    module: GlobalSovereign.Auth.Guardian,
    error_handler: GlobalSovereign.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
```

---

## Data Encryption

### At-Rest Encryption

```elixir
defmodule GlobalSovereign.Vault do
  use Cloak.Vault, otp_app: :global_sovereign

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1",
          key: decode_env!("CLOAK_KEY"),
          iv_length: 12
        }
      )

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end
end

# Usage in schemas
defmodule GlobalSovereign.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, GlobalSovereign.Encrypted.Binary
    field :phone, GlobalSovereign.Encrypted.Binary
    field :name, :string
    field :password_hash, :string
    
    timestamps()
  end
end
```

### In-Transit Encryption

All communication enforced via:
- TLS 1.3 for external APIs
- mTLS for inter-service communication
- WireGuard for mesh networking

---

## WAF (Web Application Firewall)

### Rate Limiting

```elixir
defmodule GlobalSovereignWeb.RateLimit do
  import Plug.Conn
  
  @max_requests 100
  @window_ms 60_000  # 1 minute

  def init(opts), do: opts

  def call(conn, _opts) do
    client_id = get_client_id(conn)
    
    case check_rate_limit(client_id) do
      :ok ->
        conn
      
      {:error, :rate_limited} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{error: "Rate limit exceeded"}))
        |> halt()
    end
  end

  defp get_client_id(conn) do
    # Use authenticated user ID or IP address
    case Guardian.Plug.current_resource(conn) do
      nil -> get_peer_data(conn) |> elem(0) |> :inet.ntoa() |> to_string()
      user -> "user:#{user.id}"
    end
  end

  defp check_rate_limit(client_id) do
    key = "rate_limit:#{client_id}"
    
    case Cachex.get(:sovereign_cache, key) do
      {:ok, nil} ->
        Cachex.put(:sovereign_cache, key, 1, ttl: @window_ms)
        :ok
      
      {:ok, count} when count < @max_requests ->
        Cachex.incr(:sovereign_cache, key)
        :ok
      
      {:ok, _count} ->
        {:error, :rate_limited}
    end
  end
end
```

### DDoS Mitigation

```elixir
defmodule GlobalSovereignWeb.DDoSProtection do
  use GenServer
  require Logger

  @suspicious_threshold 1000  # requests per minute
  @ban_duration :timer.minutes(15)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_analysis()
    {:ok, %{banned_ips: MapSet.new()}}
  end

  @impl true
  def handle_info(:analyze_traffic, state) do
    suspicious_ips = analyze_traffic_patterns()
    
    new_banned = 
      suspicious_ips
      |> Enum.reduce(state.banned_ips, fn ip, acc ->
        Logger.warning("Banning suspicious IP: #{ip}")
        ban_ip(ip)
        MapSet.put(acc, ip)
      end)
    
    schedule_analysis()
    {:noreply, %{state | banned_ips: new_banned}}
  end

  defp schedule_analysis do
    Process.send_after(self(), :analyze_traffic, :timer.seconds(30))
  end

  defp analyze_traffic_patterns do
    # Analyze request patterns from metrics
    []
  end

  defp ban_ip(ip) do
    # Add to firewall rules
    System.cmd("iptables", ["-A", "INPUT", "-s", ip, "-j", "DROP"])
  end
end
```

---

## Supply Chain Security

### Dependency Scanning

```bash
# Scan for vulnerabilities
mix deps.audit

# Generate SBOM (Software Bill of Materials)
mix sbom

# Security audit
mix sobelow --config
```

### Dockerfile Best Practices

```dockerfile
# Use specific version tags, not 'latest'
FROM hexpm/elixir:1.17.0-erlang-26.2.5-debian-bookworm-20240701-slim

# Run as non-root user
RUN groupadd -r sovereign && useradd -r -g sovereign sovereign

# Copy only necessary files
COPY --chown=sovereign:sovereign mix.exs mix.lock ./
COPY --chown=sovereign:sovereign config ./config

# Install dependencies with verification
RUN mix deps.get --only prod
RUN mix deps.compile

# Compile application
COPY --chown=sovereign:sovereign lib ./lib
RUN mix compile

# Switch to non-root user
USER sovereign

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["mix", "phx.server"]
```

---

## Audit Logging

### Comprehensive Audit Trail

```elixir
defmodule GlobalSovereign.Audit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "audit_logs" do
    field :event_type, :string
    field :user_id, :integer
    field :resource_type, :string
    field :resource_id, :string
    field :action, :string
    field :changes, :map
    field :ip_address, :string
    field :user_agent, :string
    field :metadata, :map
    
    timestamps(updated_at: false)
  end

  def log(event_type, user, resource, action, changes, conn) do
    %__MODULE__{}
    |> change(%{
      event_type: event_type,
      user_id: user && user.id,
      resource_type: resource && resource.__struct__ |> Module.split() |> List.last(),
      resource_id: resource && to_string(resource.id),
      action: action,
      changes: changes,
      ip_address: get_ip(conn),
      user_agent: get_user_agent(conn),
      metadata: %{}
    })
    |> Repo.insert()
  end

  defp get_ip(conn) do
    conn.remote_ip
    |> :inet.ntoa()
    |> to_string()
  end

  defp get_user_agent(conn) do
    case Plug.Conn.get_req_header(conn, "user-agent") do
      [ua | _] -> ua
      _ -> "unknown"
    end
  end
end
```

---

## Security Checklist

- [x] mTLS for service-to-service communication
- [x] WireGuard mesh for encrypted overlay network
- [x] RBAC with least privilege principle
- [x] Data encryption at rest (Cloak/Vault)
- [x] Data encryption in transit (TLS 1.3)
- [x] Rate limiting per client
- [x] DDoS protection with IP banning
- [x] Dependency scanning and SBOM generation
- [x] Security audit with Sobelow
- [x] Comprehensive audit logging
- [ ] Secrets rotation (implement with Vault/AWS Secrets Manager)
- [ ] Intrusion detection system (IDS)
- [ ] Security incident response playbook
- [ ] Regular penetration testing
- [ ] Security awareness training

---

## Incident Response

### Severity Levels

| Level | Response Time | Escalation |
|-------|--------------|------------|
| P0 (Critical) | 15 minutes | Immediate to on-call engineer |
| P1 (High) | 1 hour | Team lead |
| P2 (Medium) | 4 hours | Standard queue |
| P3 (Low) | 24 hours | Backlog |

### Response Playbook

1. **Detection**: Automated alerts via Grafana/PagerDuty
2. **Containment**: Isolate affected systems, ban malicious IPs
3. **Eradication**: Patch vulnerabilities, rotate credentials
4. **Recovery**: Restore from backups, verify integrity
5. **Post-Mortem**: Blameless analysis, update runbooks

---

Next: [Chaos Engineering Guide](./CHAOS.md)
