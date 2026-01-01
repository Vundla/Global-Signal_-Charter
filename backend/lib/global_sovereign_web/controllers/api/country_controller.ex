defmodule GlobalSovereignWeb.API.CountryController do
  use GlobalSovereignWeb, :controller

  alias GlobalSovereign.Governance

  action_fallback GlobalSovereignWeb.FallbackController

  @doc """
  List all countries in the covenant.
  """
  def index(conn, _params) do
    countries = Governance.list_countries()
    render(conn, :index, countries: countries)
  end

  @doc """
  Get covenant statistics.
  """
  def stats(conn, _params) do
    stats = Governance.covenant_stats()
    render(conn, :stats, stats: stats)
  end

  @doc """
  Show a specific country by ID.
  """
  def show(conn, %{"id" => id}) do
    country = Governance.get_country!(id)
    render(conn, :show, country: country)
  end

  @doc """
  Create a new country.
  """
  def create(conn, %{"country" => country_params}) do
    case Governance.create_country(country_params) do
      {:ok, country} ->
        conn
        |> put_status(:created)
        |> render(:show, country: country)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Update a country.
  """
  def update(conn, %{"id" => id, "country" => country_params}) do
    country = Governance.get_country!(id)

    case Governance.update_country(country, country_params) do
      {:ok, country} ->
        render(conn, :show, country: country)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Delete a country.
  """
  def delete(conn, %{"id" => id}) do
    country = Governance.get_country!(id)

    case Governance.delete_country(country) do
      {:ok, _country} ->
        send_resp(conn, :no_content, "")

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
