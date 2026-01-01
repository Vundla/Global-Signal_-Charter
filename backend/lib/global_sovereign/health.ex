defmodule GlobalSovereign.Health do
  import Ecto.Query, warn: false
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.HealthProject

  def list_projects do
    Repo.all(HealthProject)
  end

  def get_project!(id) do
    Repo.get!(HealthProject, id)
  end

  def create_project(attrs \\ %{}) do
    %HealthProject{}
    |> HealthProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%HealthProject{} = project, attrs) do
    project
    |> HealthProject.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%HealthProject{} = project) do
    Repo.delete(project)
  end

  def change_project(%HealthProject{} = project, attrs \\ %{}) do
    HealthProject.changeset(project, attrs)
  end

  def project_stats do
    Repo.one(
      from(p in HealthProject,
        select: %{
          total_projects: count(p.id),
          total_beneficiaries: sum(p.beneficiaries),
          total_facilities: sum(p.facilities_count),
          total_budget: sum(p.annual_budget_usd),
          avg_budget_per_project: avg(p.annual_budget_usd),
          avg_beneficiaries_per_project: avg(p.beneficiaries)
        }
      )
    )
    |> normalize_stats()
  end

  defp normalize_stats(nil), do: %{}
  defp normalize_stats(stats) do
    Map.new(stats, fn {k, v} -> {k, v || 0} end)
  end
end
