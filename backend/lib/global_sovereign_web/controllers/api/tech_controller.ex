defmodule GlobalSovereignWeb.API.TechController do
  use GlobalSovereignWeb, :controller
  alias GlobalSovereign.Technology
  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params), do: render(conn, :index, projects: Technology.list_projects())
  def stats(conn, _params), do: render(conn, :stats, stats: Technology.project_stats())
  def show(conn, %{"id" => id}), do: render(conn, :show, project: Technology.get_project!(id))

  def create(conn, %{"tech_project" => params}) do
    case Technology.create_project(params) do
      {:ok, project} -> conn |> put_status(:created) |> render(:show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "tech_project" => params}) do
    case Technology.update_project(Technology.get_project!(id), params) do
      {:ok, project} -> render(conn, :show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    case Technology.delete_project(Technology.get_project!(id)) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, changeset} -> {:error, changeset}
    end
  end
end
