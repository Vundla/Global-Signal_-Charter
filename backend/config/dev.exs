import Config

# Database Configuration
config :global_sovereign, GlobalSovereign.Repo,
  database: "global_DB",
  username: "global-signal_-charter",
  password: "Mv@10111",
  hostname: "localhost",
  pool_size: 10

# Phoenix Endpoint
config :global_sovereign, GlobalSovereignWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "development_secret_key_base_at_least_64_bytes_long_for_security_purposes",
  watchers: []

# Live Reload
config :global_sovereign, GlobalSovereignWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/global_sovereign_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client for dev environment
# config :swoosh, :api_client, false # Disabled - swoosh not added yet
