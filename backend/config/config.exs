import Config

# General application configuration
config :global_sovereign,
  ecto_repos: [GlobalSovereign.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :global_sovereign, GlobalSovereignWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: GlobalSovereignWeb.ErrorHTML, json: GlobalSovereignWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GlobalSovereign.PubSub,
  live_view: [signing_salt: "ubuntu_net_global"]

# Configures Elixir's Logger with structured JSON output
config :logger, :default_handler,
  config: [
    formatter: {LoggerJSON.Formatters.BasicLogger, metadata: :all}
  ]

config :logger,
  backends: [LoggerJSON],
  level: :info

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :trace_id, :user_id, :role, :status, :duration]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# PromEx Configuration
config :global_sovereign, GlobalSovereign.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

# Libcluster for distributed Erlang
config :libcluster,
  topologies: [
    ubuntu_net: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]

# Import environment specific config
import_config "#{config_env()}.exs"
