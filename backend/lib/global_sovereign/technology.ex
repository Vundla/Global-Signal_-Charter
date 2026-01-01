defmodule GlobalSovereign.Technology do
  @moduledoc """
  Context for technology projects - "Technology connects with offline-first capability."
  """
  import Ecto.Query
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.TechProject

  def list_projects, do: Repo.all(TechProject)
  def list_active_projects, do: Repo.all(from p in TechProject, where: p.status == "active")
  def get_project!(id), do: Repo.get!(TechProject, id)

  def create_project(attrs \\ %{}) do
    %TechProject{}
    |> TechProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%TechProject{} = project, attrs) do
    project |> TechProject.changeset(attrs) |> Repo.update()
  end

  def delete_project(%TechProject{} = project), do: Repo.delete(project)

  def project_stats do
    Repo.one(
      from p in TechProject,
      where: p.status == "active",
      select: %{
        total_projects: count(p.id),
        total_users_served: sum(p.users_served),
        total_contribution: sum(p.contribution_usd),
        offline_capable: filter(count(p.id), p.offline_capability == true),
        countries_participating: fragment("COUNT(DISTINCT ?)", p.country_code)
      }
    )
  end
end
