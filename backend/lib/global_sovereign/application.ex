defmodule GlobalSovereign.Application do
  @moduledoc """
  The Global Sovereign Application.
  
  Supervision tree follows "crash it if you can" philosophy:
  - Critical services restart always
  - Workers restart on failure with backoff
  - Transient services restart only on abnormal exit
  """
  use Application

  @impl true
  def start(_type, _args) do
    # Configure OpenTelemetry batch processor (skip in tests)
    if Mix.env() != :test do
      :otel_batch_processor.set_exporter(:otlp, %{
        protocol: :grpc,
        endpoints: [{~c"localhost", 4317}]
      })
    end

    prom_ex_child = if Mix.env() == :test, do: [], else: [GlobalSovereign.PromEx]

    children = [
      # Telemetry supervisor (must start first for metrics)
      GlobalSovereign.Telemetry
    ] ++ prom_ex_child ++ [
      # Database repositories
      GlobalSovereign.Repo,
      # GlobalSovereign.CassandraRepo, # TODO: Add Cassandra support
      
      # PubSub for real-time updates
      {Phoenix.PubSub, name: GlobalSovereign.PubSub},
      
      # Distributed clustering - TODO: Re-enable after basic setup
      # {Cluster.Supervisor, [topologies(), [name: GlobalSovereign.ClusterSupervisor]]},
      
      # Distributed process registry - TODO: Re-enable after basic setup
      # {Horde.Registry, [name: GlobalSovereign.ProcessRegistry, keys: :unique]},
      # {Horde.DynamicSupervisor, [
      #   name: GlobalSovereign.DistributedSupervisor,
      #   strategy: :one_for_one,
      #   members: :auto
      # ]},
      
      # Cache layer
      {Cachex, name: :sovereign_cache, limit: 10_000},
      # {Nebulex.Cache, name: GlobalSovereign.Cache}, # TODO: Configure Nebulex
      
      # Phoenix Endpoint
      GlobalSovereignWeb.Endpoint,
      
      # Orchestration layer - TODO: Implement
      # GlobalSovereign.Orchestrator.Supervisor,
      
      # Sync layer - TODO: Implement
      # GlobalSovereign.Sync.Supervisor,
      
      # Cache warmers - TODO: Implement
      # GlobalSovereign.CacheWarmer.Supervisor,
      
      # Event gateway - TODO: Implement
      # GlobalSovereign.Events.Supervisor,
      
      # AI observability (transient restart) - TODO: Implement
      # {GlobalSovereign.AI.Supervisor, restart: :transient},
      
      # Power management - TODO: Implement
      # GlobalSovereign.Power.Manager,
      
      # Circuit breaker registry - TODO: Implement
      # GlobalSovereign.CircuitBreaker.Supervisor
    ]

    opts = [strategy: :one_for_one, name: GlobalSovereign.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GlobalSovereignWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Cluster topology configuration
  defp topologies do
    [
      sovereign: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "230.1.1.251",
          multicast_ttl: 1,
          secret: System.get_env("CLUSTER_SECRET", "sovereign_secret")
        ]
      ],
      fly: [
        strategy: Elixir.Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 5_000,
          query: System.get_env("FLY_APP_NAME", "global-sovereign") <> ".internal",
          node_basename: System.get_env("FLY_APP_NAME", "global-sovereign")
        ]
      ]
    ]
  end
end
