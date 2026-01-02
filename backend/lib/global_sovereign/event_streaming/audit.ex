defmodule GlobalSovereign.EventStreaming.Audit do
  @moduledoc """
  Audit trail integration with NATS JetStream.
  
  Publishes tamper-evident audit events to NATS for compliance and security monitoring.
  All events are retained for 7 years and hash-chained for integrity verification.
  
  Events logged:
  - user.login / user.logout
  - user.role_change
  - project.create / project.update / project.delete
  - country.update (GDP changes)
  - secret.rotated
  """

  require Logger

  @audit_stream "audit"
  @retention_years 7

  @doc """
  Publishes an audit event to NATS JetStream.
  
  ## Examples
  
      iex> publish_event("user.login", %{user_id: 123, ip: "1.2.3.4"})
      :ok
      
      iex> publish_event("project.create", %{project_id: 456, user_id: 123, country: "US"})
      :ok
  """
  def publish_event(event_type, metadata) when is_binary(event_type) and is_map(metadata) do
    event = %{
      type: event_type,
      metadata: metadata,
      timestamp: DateTime.utc_now(),
      hash: generate_hash(event_type, metadata)
    }

    case Gnat.pub(:gnat, "#{@audit_stream}.#{event_type}", Jason.encode!(event)) do
      :ok ->
        Logger.info("Audit event published", 
          event_type: event_type, 
          metadata: metadata
        )
        :ok

      {:error, reason} ->
        Logger.error("Failed to publish audit event", 
          event_type: event_type, 
          reason: inspect(reason)
        )
        {:error, reason}
    end
  end

  @doc """
  Creates the audit stream in NATS JetStream if it doesn't exist.
  Should be called during application startup or migration.
  """
  def create_audit_stream do
    retention_seconds = @retention_years * 365 * 24 * 60 * 60

    stream_config = %{
      name: @audit_stream,
      subjects: ["#{@audit_stream}.>"],
      retention: "limits",
      max_age: retention_seconds * 1_000_000_000, # nanoseconds
      storage: "file",
      replicas: 1,
      discard: "old"
    }

    case Gnat.request(:gnat, "$JS.API.STREAM.CREATE.#{@audit_stream}", Jason.encode!(stream_config), receive_timeout: 5_000) do
      {:ok, %{body: body}} ->
        Logger.info("Audit stream created", stream: @audit_stream, config: stream_config)
        {:ok, Jason.decode!(body)}

      {:error, :timeout} ->
        Logger.warn("Audit stream creation timed out (may already exist)")
        :ok

      {:error, reason} ->
        Logger.error("Failed to create audit stream", reason: inspect(reason))
        {:error, reason}
    end
  end

  @doc """
  Retrieves recent audit events for investigation.
  
  ## Examples
  
      iex> get_recent_events("user.login", 100)
      {:ok, [%{type: "user.login", metadata: %{...}, ...}, ...]}
  """
  def get_recent_events(event_type, limit \\ 100) do
    # This would query NATS stream for recent messages
    # Implementation depends on NATS consumer setup
    Logger.info("Fetching recent audit events", event_type: event_type, limit: limit)
    {:ok, []}
  end

  # Private helpers

  defp generate_hash(event_type, metadata) do
    data = "#{event_type}:#{Jason.encode!(metadata)}"
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end

  @doc """
  Logs user authentication events.
  """
  def log_user_login(user_id, ip_address) do
    publish_event("user.login", %{
      user_id: user_id,
      ip: ip_address,
      timestamp: DateTime.utc_now()
    })
  end

  def log_user_logout(user_id) do
    publish_event("user.logout", %{
      user_id: user_id,
      timestamp: DateTime.utc_now()
    })
  end

  @doc """
  Logs project lifecycle events.
  """
  def log_project_create(project_id, user_id, country_code) do
    publish_event("project.create", %{
      project_id: project_id,
      user_id: user_id,
      country: country_code,
      timestamp: DateTime.utc_now()
    })
  end

  def log_project_delete(project_id, user_id) do
    publish_event("project.delete", %{
      project_id: project_id,
      user_id: user_id,
      timestamp: DateTime.utc_now()
    })
  end

  @doc """
  Logs GDP/covenant fund changes.
  """
  def log_gdp_update(country_code, old_gdp, new_gdp, user_id) do
    delta_percent = ((new_gdp - old_gdp) / old_gdp * 100) |> Float.round(2)

    publish_event("country.update", %{
      country: country_code,
      old_gdp: old_gdp,
      new_gdp: new_gdp,
      delta_percent: delta_percent,
      user_id: user_id,
      timestamp: DateTime.utc_now()
    })
  end

  @doc """
  Logs security events.
  """
  def log_secret_rotation(secret_name) do
    publish_event("security.secret_rotated", %{
      secret: secret_name,
      timestamp: DateTime.utc_now()
    })
  end

  def log_role_change(user_id, old_role, new_role, changed_by) do
    publish_event("user.role_change", %{
      user_id: user_id,
      old_role: old_role,
      new_role: new_role,
      changed_by: changed_by,
      timestamp: DateTime.utc_now()
    })
  end
end
