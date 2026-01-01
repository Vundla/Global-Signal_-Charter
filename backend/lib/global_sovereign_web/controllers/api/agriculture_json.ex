defmodule GlobalSovereignWeb.API.AgricultureJSON do
  alias GlobalSovereign.Schema.AgricultureProject

  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  def stats(%{stats: stats}) do
    %{
      data: %{
        total_projects: stats.total_projects || 0,
        total_contribution_usd: stats.total_contribution || 0,
        total_yield_kg: stats.total_yield || 0,
        countries_participating: stats.countries_participating || 0
      }
    }
  end

  def show(%{project: project}) do
    %{data: data(project)}
  end

  defp data(%AgricultureProject{} = project) do
    %{
      id: project.id,
      country_code: project.country_code,
      project_name: project.project_name,
      crop_type: project.crop_type,
      yield_estimate: project.yield_estimate,
      irrigation_method: project.irrigation_method,
      contribution_usd: project.contribution_usd,
      status: project.status
    }
  end
end
