defmodule GlobalSovereignWeb.API.EnergyController do
  use GlobalSovereignWeb, :controller
  alias GlobalSovereign.Energy
  action_fallback GlobalSovereignWeb.FallbackController

  def index(conn, _params), do: render(conn, :index, projects: Energy.list_projects())
  def stats(conn, _params), do: render(conn, :stats, stats: Energy.project_stats())
  def show(conn, %{"id" => id}), do: render(conn, :show, project: Energy.get_project!(id))

  def create(conn, %{"energy_project" => params}) do
    case Energy.create_project(params) do
      {:ok, project} -> conn |> put_status(:created) |> render(:show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "energy_project" => params}) do
    case Energy.update_project(Energy.get_project!(id), params) do
      {:ok, project} -> render(conn, :show, project: project)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    case Energy.delete_project(Energy.get_project!(id)) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, changeset} -> {:error, changeset}
    end
  end
end
