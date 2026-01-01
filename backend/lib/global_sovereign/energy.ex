defmodule GlobalSovereign.Energy do
  @moduledoc """
  Context for energy projects - "Energy empowers with resilience reserves."
  """
  import Ecto.Query
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.EnergyProject

  def list_projects, do: Repo.all(EnergyProject)
  def list_active_projects, do: Repo.all(from p in EnergyProject, where: p.status == "active")
  def get_project!(id), do: Repo.get!(EnergyProject, id)

  def create_project(attrs \\ %{}) do
    %EnergyProject{}
    |> EnergyProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%EnergyProject{} = project, attrs) do
    project |> EnergyProject.changeset(attrs) |> Repo.update()
  end

  def delete_project(%EnergyProject{} = project), do: Repo.delete(project)

  def project_stats do
    Repo.one(
      from p in EnergyProject,
      where: p.status == "active",
      select: %{
        total_projects: count(p.id),
        total_capacity_mw: sum(p.capacity_mw),
        avg_uptime: avg(p.uptime_percent),
        total_profit: sum(p.profit_usd),
        resilience_reserves: sum(p.resilience_reserve_usd),
        countries_participating: fragment("COUNT(DISTINCT ?)", p.country_code)
      }
    )
  end
end
