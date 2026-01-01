defmodule GlobalSovereignWeb.API.EducationController do
  use GlobalSovereignWeb, :controller

  alias GlobalSovereign.Education
  alias GlobalSovereign.Schema.EducationProject

  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params) do
    projects = Education.list_projects()
    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => id}) do
    project = Education.get_project!(id)
    render(conn, :show, project: project)
  end

  def stats(conn, _params) do
    stats = Education.project_stats()
    render(conn, :stats, stats: stats)
  end

  def create(conn, %{"education_project" => education_project_params}) do
    with {:ok, %EducationProject{} = project} <- Education.create_project(education_project_params) do
      conn
      |> put_status(:created)
      |> render(:show, project: project)
    end
  end

  def update(conn, %{"id" => id, "education_project" => education_project_params}) do
    project = Education.get_project!(id)

    with {:ok, %EducationProject{} = project} <- Education.update_project(project, education_project_params) do
      render(conn, :show, project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Education.get_project!(id)

    with {:ok, _} <- Education.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
