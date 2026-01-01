defmodule GlobalSovereign.Education do
  import Ecto.Query, warn: false
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.EducationProject

  def list_projects do
    Repo.all(EducationProject)
  end

  def get_project!(id) do
    Repo.get!(EducationProject, id)
  end

  def create_project(attrs \\ %{}) do
    %EducationProject{}
    |> EducationProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%EducationProject{} = project, attrs) do
    project
    |> EducationProject.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%EducationProject{} = project) do
    Repo.delete(project)
  end

  def change_project(%EducationProject{} = project, attrs \\ %{}) do
    EducationProject.changeset(project, attrs)
  end

  def project_stats do
    Repo.one(
      from(p in EducationProject,
        select: %{
          total_projects: count(p.id),
          total_students: sum(p.students_reached),
          total_teachers_trained: sum(p.teachers_trained),
          total_schools: sum(p.schools_built),
          total_budget: sum(p.annual_budget_usd),
          avg_budget_per_project: avg(p.annual_budget_usd),
          avg_students_per_project: avg(p.students_reached)
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
