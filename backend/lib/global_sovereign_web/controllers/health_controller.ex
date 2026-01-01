defmodule GlobalSovereignWeb.HealthController do
  use GlobalSovereignWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok", service: "global-sovereign"})
  end
end
