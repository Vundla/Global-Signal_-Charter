defmodule GlobalSovereignWeb.API.MineralJSON do
  alias GlobalSovereign.Schema.MineralProject

  def index(%{projects: projects}), do: %{data: for(p <- projects, do: data(p))}
  def stats(%{stats: s}), do: %{data: %{total_projects: s.total_projects || 0, total_profit_usd: s.total_profit || 0, local_reinvestment_usd: s.local_reinvestment || 0, global_contribution_usd: s.global_contribution || 0, countries_participating: s.countries_participating || 0}}
  def show(%{project: project}), do: %{data: data(project)}

  defp data(%MineralProject{} = p), do: %{id: p.id, country_code: p.country_code, resource_type: p.resource_type, extraction_volume: p.extraction_volume, profit_usd: p.profit_usd, local_reinvestment_usd: p.local_reinvestment_usd, global_contribution_usd: p.global_contribution_usd, status: p.status}
end
