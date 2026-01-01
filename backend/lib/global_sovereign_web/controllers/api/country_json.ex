defmodule GlobalSovereignWeb.API.CountryJSON do
  alias GlobalSovereign.Schema.Country

  @doc """
  Renders a list of countries.
  """
  def index(%{countries: countries}) do
    %{data: for(country <- countries, do: data(country))}
  end

  @doc """
  Renders covenant statistics.
  """
  def stats(%{stats: stats}) do
    %{
      data: %{
        total_countries: stats.total_countries,
        active_countries: stats.active_countries,
        total_gdp_usd: stats.total_gdp || 0,
        total_fund_usd: stats.total_fund || 0
      }
    }
  end

  @doc """
  Renders a single country.
  """
  def show(%{country: country}) do
    %{data: data(country)}
  end

  defp data(%Country{} = country) do
    %{
      id: country.id,
      name: country.name,
      code: country.code,
      gdp_usd: country.gdp_usd,
      contribution_usd: country.contribution_usd,
      covenant_status: country.covenant_status,
      joined_at: country.joined_at
    }
  end
end
