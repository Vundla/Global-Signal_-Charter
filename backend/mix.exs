defmodule GlobalSovereign.MixProject do
  use Mix.Project

  def project do
    [
      app: :global_sovereign,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [
      mod: {GlobalSovereign.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix Framework
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 0.20.17"},
      {:phoenix_live_dashboard, "~> 0.8.4"},
      
      # Database
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:xandra, "~> 0.18"}, # Cassandra driver
      
      # Caching & Queuing
      {:cachex, "~> 3.6"},
      {:nebulex, "~> 2.6"},
      {:broadway, "~> 1.1"},
      
      # Events & Messaging
      {:gnat, "~> 1.8"}, # NATS client
      # {:kaffe, "~> 1.28"}, # Kafka client - disabled, requires snappyer NIF compilation
      
      # HTTP & WebSocket
      {:plug_cowboy, "~> 2.7"},
      {:cors_plug, "~> 3.0"},
      {:websockex, "~> 0.4"},
      
      # GraphQL
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0"},
      
      # Authentication & Security
      # {:guardian, "~> 2.4"}, # Disabled temporarily - jose dependency compilation issues
      {:comeonin, "~> 5.4"},
      {:bcrypt_elixir, "~> 3.1"},
      # {:x509, "~> 0.9"}, # Certificate management - disabled due to Erlang version incompatibility
      
      # Observability
      {:prom_ex, "~> 1.10"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:opentelemetry, "~> 1.4"},
      {:opentelemetry_exporter, "~> 1.7"},
      {:opentelemetry_phoenix, "~> 1.2"},
      {:opentelemetry_ecto, "~> 1.2"},
      
      # Distributed Systems
      {:libcluster, "~> 3.4"},
      {:horde, "~> 0.9"}, # Distributed process registry
      {:swarm, "~> 3.4"}, # Distributed process groups
      
      # IPFS & Content Addressing
      # {:ex_ipfs, "~> 0.1"}, # Disabled - requires Rust toolchain
      # {:multihash, "~> 2.1"}, # Disabled - requires Rust toolchain
      
      # S3/MinIO
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},
      {:hackney, "~> 1.20"},
      {:sweet_xml, "~> 0.7"},
      
      # JSON
      {:jason, "~> 1.4"},
      {:poison, "~> 5.0"},
      
      # Utilities
      {:timex, "~> 3.7"},
      {:decimal, "~> 2.1"},
      {:ecto_enum, "~> 1.4"},
      {:nanoid, "~> 2.1"},
      
      # Circuit Breaker & Retry
      {:fuse, "~> 2.5"},
      {:retry, "~> 0.18"},
      
      # Cryptography
      {:cloak, "~> 1.1"},
      {:cloak_ecto, "~> 1.3"},
      
      # Testing
      {:ex_machina, "~> 2.8", only: :test},
      {:faker, "~> 0.18", only: :test},
      {:mox, "~> 1.1", only: :test},
      {:stream_data, "~> 1.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.18", only: :test},
      
      # Development
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
