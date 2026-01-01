defmodule GlobalSovereign.Minerals do
  @moduledoc """
  Context for mineral projects - "Minerals sustain with transparent profit-sharing."
  """
  import Ecto.Query
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.MineralProject

  def list_projects, do: Repo.all(MineralProject)
  def list_active_projects, do: Repo.all(from p in MineralProject, where: p.status == "active")
  def get_project!(id), do: Repo.get!(MineralProject, id)

  def create_project(attrs \\ %{}) do
    %MineralProject{}
    |> MineralProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%MineralProject{} = project, attrs) do
    project |> MineralProject.changeset(attrs) |> Repo.update()
  end

  def delete_project(%MineralProject{} = project), do: Repo.delete(project)

  def project_stats do
    Repo.one(
      from p in MineralProject,
      where: p.status == "active",
      select: %{
        total_projects: count(p.id),
        total_profit: sum(p.profit_usd),
        local_reinvestment: sum(p.local_reinvestment_usd),
        global_contribution: sum(p.global_contribution_usd),
        countries_participating: fragment("COUNT(DISTINCT ?)", p.country_code)
      }
    )
  end
end
