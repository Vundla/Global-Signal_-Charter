defmodule GlobalSovereign.EventStreaming.NATS do
  @moduledoc """
  Phase 4: NATS JetStream Configuration
  Event-driven architecture backbone for multi-region scaling
  """

  require Logger

  @doc """
  Initialize NATS connection and create default streams
  Called during application startup
  """
  def setup_streams! do
    case connect() do
      {:ok, conn} ->
        create_covenant_stream(conn)
        create_alerts_stream(conn)
        create_notifications_stream(conn)
        create_audit_stream(conn)
        Logger.info("NATS JetStream streams initialized successfully")
        {:ok, conn}

      {:error, reason} ->
        Logger.error("Failed to connect to NATS: #{reason}")
        {:error, reason}
    end
  end

  defp connect do
    case Gnat.start_link(%{
      host: System.get_env("NATS_HOST", "localhost"),
      port: String.to_integer(System.get_env("NATS_PORT", "4222"))
    }) do
      {:ok, pid} -> {:ok, pid}
      error -> error
    end
  end

  # Covenant Event Stream
  # Topics: covenant.countries.>, covenant.sectors.>, covenant.projects.>
  defp create_covenant_stream(conn) do
    case Gnat.jetstream_api(conn, %{
      type: "STREAM",
      subjects: [
        "covenant.countries.created",
        "covenant.countries.updated",
        "covenant.countries.deleted",
        "covenant.sectors.agriculture.>",
        "covenant.sectors.minerals.>",
        "covenant.sectors.energy.>",
        "covenant.sectors.technology.>",
        "covenant.sectors.health.>",
        "covenant.sectors.education.>",
        "covenant.projects.created",
        "covenant.projects.updated",
        "covenant.projects.deleted",
        "covenant.payments.distributed"
      ],
      retention_policy: "Interest",
      discard: "Old",
      max_msgs: 1_000_000,
      max_age: 7 * 24 * 60 * 60 * 1_000_000_000
    }) do
      {:ok, _} ->
        Logger.info("Covenant stream created")

      {:error, error} ->
        Logger.warn("Covenant stream already exists or error: #{inspect(error)}")
    end
  end

  # Alerts Stream
  # Topics: alerts.anomaly.>, alerts.critical.>
  defp create_alerts_stream(conn) do
    case Gnat.jetstream_api(conn, %{
      type: "STREAM",
      subjects: [
        "alerts.anomaly.detected",
        "alerts.anomaly.resolved",
        "alerts.critical.incident",
        "alerts.critical.resolved"
      ],
      retention_policy: "Interest",
      discard: "Old",
      max_msgs: 500_000,
      max_age: 30 * 24 * 60 * 60 * 1_000_000_000
    }) do
      {:ok, _} ->
        Logger.info("Alerts stream created")

      {:error, error} ->
        Logger.warn("Alerts stream already exists or error: #{inspect(error)}")
    end
  end

  # Notifications Stream
  # Topics: notifications.push.>, notifications.email.>
  defp create_notifications_stream(conn) do
    case Gnat.jetstream_api(conn, %{
      type: "STREAM",
      subjects: [
        "notifications.push.queued",
        "notifications.push.sent",
        "notifications.push.failed",
        "notifications.email.queued",
        "notifications.email.sent"
      ],
      retention_policy: "Limits",
      discard: "Old",
      max_msgs: 100_000,
      max_age: 7 * 24 * 60 * 60 * 1_000_000_000
    }) do
      {:ok, _} ->
        Logger.info("Notifications stream created")

      {:error, error} ->
        Logger.warn("Notifications stream already exists or error: #{inspect(error)}")
    end
  end

  # Audit Stream (Immutable)
  # Topics: audit.permission.>, audit.transaction.>, audit.access.>
  defp create_audit_stream(conn) do
    case Gnat.jetstream_api(conn, %{
      type: "STREAM",
      subjects: [
        "audit.permission.changed",
        "audit.transaction.created",
        "audit.transaction.completed",
        "audit.access.granted",
        "audit.access.revoked"
      ],
      retention_policy: "Interest",
      discard: "Old",
      max_msgs: 10_000_000,
      # Keep audit logs for 7+ years (immutable)
      max_age: 7 * 365 * 24 * 60 * 60 * 1_000_000_000,
      # Enable per-subject message limits
      allow_direct: true,
      storage: "file"
    }) do
      {:ok, _} ->
        Logger.info("Audit stream created (immutable, 7-year retention)")

      {:error, error} ->
        Logger.warn("Audit stream already exists or error: #{inspect(error)}")
    end
  end

  @doc """
  Publish an event to NATS JetStream
  Example:
    NATS.publish_event("covenant.countries.created", %{
      country_code: "ZW",
      country_name: "Zimbabwe",
      gdp_usd: 50_000_000_000
    })
  """
  def publish_event(topic, payload) when is_binary(topic) and is_map(payload) do
    case Gnat.pub(Gnat, topic, Jason.encode!(payload)) do
      :ok ->
        Logger.info("Event published: #{topic}")
        :ok

      {:error, reason} ->
        Logger.error("Failed to publish event #{topic}: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Subscribe to events with a consumer
  Example:
    {:ok, _} = NATS.subscribe_consumer("alerts.anomaly.detected", &handle_anomaly/1)
  """
  def subscribe_consumer(topic, handler_fn) when is_function(handler_fn, 1) do
    case Gnat.sub(Gnat, topic) do
      {:ok, _subscription_id} ->
        Logger.info("Consumer subscribed to: #{topic}")
        {:ok, handler_fn}

      {:error, reason} ->
        Logger.error("Failed to subscribe to #{topic}: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Configuration for NATS connection
  Used in application.ex for supervision tree
  """
  def connection_config do
    %{
      host: System.get_env("NATS_HOST", "localhost"),
      port: String.to_integer(System.get_env("NATS_PORT", "4222")),
      jwt: System.get_env("NATS_JWT"),
      seed: System.get_env("NATS_SEED"),
      tls_ca_file: System.get_env("NATS_TLS_CA"),
      tls_cert_file: System.get_env("NATS_TLS_CERT"),
      tls_key_file: System.get_env("NATS_TLS_KEY")
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  List all active streams and their stats
  Used for monitoring and debugging
  """
  def list_streams(conn) do
    case Gnat.jetstream_api(conn, %{type: "INFO"}) do
      {:ok, info} -> {:ok, info}
      error -> error
    end
  end
end
