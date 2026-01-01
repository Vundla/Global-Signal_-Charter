defmodule GlobalSovereignWeb.API.EducationJSON do
  def index(%{projects: projects}) do
    %{data: Enum.map(projects, &data/1)}
  end

  def show(%{project: project}) do
    %{data: data(project)}
  end

  def stats(%{stats: stats}) do
    %{data: stats}
  end

  defp data(%GlobalSovereign.Schema.EducationProject{} = project) do
    %{
      id: project.id,
      country_code: project.country_code,
      project_name: project.project_name,
      education_level: project.education_level,
      students_reached: project.students_reached,
      teachers_trained: project.teachers_trained,
      schools_built: project.schools_built,
      annual_budget_usd: project.annual_budget_usd,
      status: project.status,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end
end
