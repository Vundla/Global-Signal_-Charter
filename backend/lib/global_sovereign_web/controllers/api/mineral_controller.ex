defmodule GlobalSovereignWeb.API.MineralController do
  use GlobalSovereignWeb, :controller
  alias GlobalSovereign.Minerals
  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params), do: render(conn, :index, projects: Minerals.list_projects())
  def stats(conn, _params), do: render(conn, :stats, stats: Minerals.project_stats())
  def show(conn, %{"id" => id}), do: render(conn, :show, project: Minerals.get_project!(id))

  def create(conn, %{"mineral_project" => params}) do
    case Minerals.create_project(params) do
      {:ok, project} -> conn |> put_status(:created) |> render(:show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "mineral_project" => params}) do
    case Minerals.update_project(Minerals.get_project!(id), params) do
      {:ok, project} -> render(conn, :show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    case Minerals.delete_project(Minerals.get_project!(id)) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, changeset} -> {:error, changeset}
    end
  end
end
