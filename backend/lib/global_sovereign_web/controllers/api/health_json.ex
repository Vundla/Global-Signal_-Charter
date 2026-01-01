defmodule GlobalSovereignWeb.API.HealthJSON do
  def index(%{projects: projects}) do
    %{data: Enum.map(projects, &data/1)}
  end

  def show(%{project: project}) do
    %{data: data(project)}
  end

  def stats(%{stats: stats}) do
    %{data: stats}
  end

  defp data(%GlobalSovereign.Schema.HealthProject{} = project) do
    %{
      id: project.id,
      country_code: project.country_code,
      project_name: project.project_name,
      health_type: project.health_type,
      beneficiaries: project.beneficiaries,
      facilities_count: project.facilities_count,
      annual_budget_usd: project.annual_budget_usd,
      status: project.status,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end
end
