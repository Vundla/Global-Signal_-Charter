defmodule GlobalSovereignWeb.API.TechJSON do
  alias GlobalSovereign.Schema.TechProject

  def index(%{projects: projects}), do: %{data: for(p <- projects, do: data(p))}
  def stats(%{stats: s}), do: %{data: %{total_projects: s.total_projects || 0, total_users_served: s.total_users_served || 0, total_contribution_usd: s.total_contribution || 0, offline_capable_projects: s.offline_capable || 0, countries_participating: s.countries_participating || 0}}
  def show(%{project: project}), do: %{data: data(project)}

  defp data(%TechProject{} = p), do: %{id: p.id, country_code: p.country_code, project_name: p.project_name, sector: p.sector, offline_capability: p.offline_capability, users_served: p.users_served, contribution_usd: p.contribution_usd, status: p.status}
end
