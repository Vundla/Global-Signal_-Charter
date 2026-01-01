defmodule GlobalSovereign.Telemetry do
  @moduledoc """
  Telemetry supervisor for Global Sovereign metrics and monitoring.
  """
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller for periodic measurements
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp periodic_measurements do
    [
      # VM measurements
      {__MODULE__, :measure_vm, []},
      
      # Database measurements
      {__MODULE__, :measure_db, []}
    ]
  end

  def measure_vm do
    :telemetry.execute(
      [:vm, :memory],
      :erlang.memory(),
      %{}
    )
    
    :telemetry.execute(
      [:vm, :system_counts],
      %{
        process_count: :erlang.system_info(:process_count),
        port_count: :erlang.system_info(:port_count)
      },
      %{}
    )
  end

  def measure_db do
    # Database connection pool measurements
    :telemetry.execute(
      [:global_sovereign, :repo, :pool],
      %{
        # Add pool stats here when repo is available
      },
      %{}
    )
  end
end
