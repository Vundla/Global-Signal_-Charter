defmodule GlobalSovereignWeb.API.HealthController do
  use GlobalSovereignWeb, :controller

  alias GlobalSovereign.Health
  alias GlobalSovereign.Schema.HealthProject

  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params) do
    projects = Health.list_projects()
    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => id}) do
    project = Health.get_project!(id)
    render(conn, :show, project: project)
  end

  def stats(conn, _params) do
    stats = Health.project_stats()
    render(conn, :stats, stats: stats)
  end

  def create(conn, %{"health_project" => health_project_params}) do
    with {:ok, %HealthProject{} = project} <- Health.create_project(health_project_params) do
      conn
      |> put_status(:created)
      |> render(:show, project: project)
    end
  end

  def update(conn, %{"id" => id, "health_project" => health_project_params}) do
    project = Health.get_project!(id)

    with {:ok, %HealthProject{} = project} <- Health.update_project(project, health_project_params) do
      render(conn, :show, project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Health.get_project!(id)

    with {:ok, _} <- Health.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
