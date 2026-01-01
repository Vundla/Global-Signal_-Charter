defmodule GlobalSovereignWeb.API.AgricultureController do
  use GlobalSovereignWeb, :controller
  alias GlobalSovereign.Agriculture

  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params) do
    projects = Agriculture.list_projects()
    render(conn, :index, projects: projects)
  end

  def stats(conn, _params) do
    stats = Agriculture.project_stats()
    render(conn, :stats, stats: stats)
  end

  def show(conn, %{"id" => id}) do
    project = Agriculture.get_project!(id)
    render(conn, :show, project: project)
  end

  def create(conn, %{"agriculture_project" => project_params}) do
    case Agriculture.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> render(:show, project: project)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "agriculture_project" => project_params}) do
    project = Agriculture.get_project!(id)
    case Agriculture.update_project(project, project_params) do
      {:ok, project} -> render(conn, :show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Agriculture.get_project!(id)
    case Agriculture.delete_project(project) do
      {:ok, _project} -> send_resp(conn, :no_content, "")
      {:error, changeset} -> {:error, changeset}
    end
  end
end
