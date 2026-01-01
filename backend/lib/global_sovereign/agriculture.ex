defmodule GlobalSovereign.Agriculture do
  @moduledoc """
  Context for agriculture projects - "Agriculture feeds the covenant."
  """
  import Ecto.Query
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.AgricultureProject

  def list_projects do
    Repo.all(AgricultureProject)
  end

  def list_active_projects do
    AgricultureProject
    |> where([p], p.status == "active")
    |> Repo.all()
  end

  def get_project!(id), do: Repo.get!(AgricultureProject, id)

  def create_project(attrs \\ %{}) do
    %AgricultureProject{}
    |> AgricultureProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%AgricultureProject{} = project, attrs) do
    project
    |> AgricultureProject.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%AgricultureProject{} = project) do
    Repo.delete(project)
  end

  def project_stats do
    Repo.one(
      from p in AgricultureProject,
      where: p.status == "active",
      select: %{
        total_projects: count(p.id),
        total_contribution: sum(p.contribution_usd),
        total_yield: sum(p.yield_estimate),
        countries_participating: fragment("COUNT(DISTINCT ?)", p.country_code)
      }
    )
  end
end
