defmodule GlobalSovereignWeb.API.EnergyJSON do
  alias GlobalSovereign.Schema.EnergyProject

  def index(%{projects: projects}), do: %{data: for(p <- projects, do: data(p))}
  def stats(%{stats: s}), do: %{data: %{total_projects: s.total_projects || 0, total_capacity_mw: s.total_capacity_mw || 0, avg_uptime_percent: s.avg_uptime && Decimal.to_float(s.avg_uptime) || 0, total_profit_usd: s.total_profit || 0, resilience_reserves_usd: s.resilience_reserves || 0, countries_participating: s.countries_participating || 0}}
  def show(%{project: project}), do: %{data: data(project)}

  defp data(%EnergyProject{} = p), do: %{id: p.id, country_code: p.country_code, project_name: p.project_name, source_type: p.source_type, capacity_mw: p.capacity_mw, uptime_percent: p.uptime_percent, profit_usd: p.profit_usd, resilience_reserve_usd: p.resilience_reserve_usd, status: p.status}
end
