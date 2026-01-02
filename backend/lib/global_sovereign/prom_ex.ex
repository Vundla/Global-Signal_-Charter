defmodule GlobalSovereign.PromEx do
  @moduledoc """
  PromEx module for comprehensive metrics collection.
  
  Collects metrics for:
  - Phoenix endpoints (request rate, latency, status codes)
  - Ecto queries (query time, decode time, pool size)
  - BEAM VM (memory, reductions, processes, GC)
  - Custom business metrics (covenant fund, projects, countries)
  """
  use PromEx, otp_app: :global_sovereign

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      # Standard Elixir/Phoenix plugins
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: GlobalSovereignWeb.Router, endpoint: GlobalSovereignWeb.Endpoint},
      {Plugins.Ecto, otp_app: :global_sovereign, repos: [GlobalSovereign.Repo]},
      
      # Custom covenant metrics
      GlobalSovereign.PromEx.CovenantPlugin
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "prometheus",
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    [
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "phoenix.json"},
      {:prom_ex, "ecto.json"}
    ]
  end
end
