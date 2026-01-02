defmodule GlobalSovereign.PromEx.CovenantPlugin do
  @moduledoc """
  Custom PromEx plugin for covenant-specific business metrics.
  
  Metrics:
  - Total countries in system
  - Total projects created
  - Covenant fund total (GDP sum)
  - Project creation rate
  - User count by role
  """
  use PromEx.Plugin

  @impl true
  def polling_metrics(opts) do
    poll_rate = Keyword.get(opts, :poll_rate, 30_000)

    [
      covenant_metrics(poll_rate)
    ]
  end

  defp covenant_metrics(poll_rate) do
    Polling.build(
      :covenant_metrics_poller,
      poll_rate,
      {__MODULE__, :execute_covenant_metrics, []},
      [
        # Total countries metric
        last_value(
          [:global_sovereign, :covenant, :countries, :total],
          event_name: [:prom_ex, :plugin, :covenant, :countries, :total],
          description: "Total number of countries in the system",
          measurement: :count,
          unit: :unit
        ),

        # Total projects metric
        last_value(
          [:global_sovereign, :covenant, :projects, :total],
          event_name: [:prom_ex, :plugin, :covenant, :projects, :total],
          description: "Total number of projects created",
          measurement: :count,
          unit: :unit
        ),

        # Covenant fund (GDP sum)
        last_value(
          [:global_sovereign, :covenant, :fund, :total],
          event_name: [:prom_ex, :plugin, :covenant, :fund, :total],
          description: "Total covenant fund (sum of all country GDPs)",
          measurement: :amount,
          unit: :unit
        ),

        # User count
        last_value(
          [:global_sovereign, :users, :total],
          event_name: [:prom_ex, :plugin, :users, :total],
          description: "Total registered users",
          measurement: :count,
          unit: :unit
        )
      ]
    )
  end

  @doc false
  def execute_covenant_metrics do
    import Ecto.Query

    # Count countries
    country_count = GlobalSovereign.Repo.one(
      from c in "countries_phase4", select: count(c.id)
    ) || 0

    # Count projects
    project_count = GlobalSovereign.Repo.one(
      from p in "projects_phase4", select: count(p.id)
    ) || 0

    # Calculate covenant fund (sum of GDPs)
    covenant_fund = GlobalSovereign.Repo.one(
      from c in "countries_phase4", select: sum(c.gdp)
    ) || Decimal.new(0)

    # Count users
    user_count = GlobalSovereign.Repo.one(
      from u in "users", select: count(u.id)
    ) || 0

    # Emit telemetry events
    :telemetry.execute(
      [:prom_ex, :plugin, :covenant, :countries, :total],
      %{count: country_count}
    )

    :telemetry.execute(
      [:prom_ex, :plugin, :covenant, :projects, :total],
      %{count: project_count}
    )

    :telemetry.execute(
      [:prom_ex, :plugin, :covenant, :fund, :total],
      %{amount: Decimal.to_float(covenant_fund)}
    )

    :telemetry.execute(
      [:prom_ex, :plugin, :users, :total],
      %{count: user_count}
    )
  end
end
