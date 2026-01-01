defmodule GlobalSovereign.Governance do
  @moduledoc """
  Context for governance operations including country management,
  covenant participation, and contribution tracking.
  """

  import Ecto.Query, warn: false
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.Country

  @doc """
  Returns the list of countries in the covenant.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Returns the list of active countries.

  ## Examples

      iex> list_active_countries()
      [%Country{covenant_status: :active}, ...]

  """
  def list_active_countries do
    Country
    |> where([c], c.covenant_status == "active")
    |> Repo.all()
  end

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Gets a country by its ISO code.

  ## Examples

      iex> get_country_by_code("ZAF")
      %Country{code: "ZAF"}

      iex> get_country_by_code("XXX")
      nil

  """
  def get_country_by_code(code) do
    Repo.get_by(Country, code: code)
  end

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  @doc """
  Calculates total annual fund from all active countries.

  ## Examples

      iex> calculate_total_fund()
      %Decimal{coef: 9390000000}

  """
  def calculate_total_fund do
    Country
    |> where([c], c.covenant_status == "active")
    |> select([c], sum(c.contribution_usd))
    |> Repo.one()
    |> case do
      nil -> 0
      total -> total
    end
  end

  @doc """
  Returns covenant statistics.

  ## Examples

      iex> covenant_stats()
      %{
        total_countries: 56,
        active_countries: 56,
        total_gdp: %Decimal{},
        total_fund: %Decimal{},
        total_population: 5_800_000_000
      }

  """
  def covenant_stats do
    stats = Repo.one(
      from c in Country,
      select: %{
        total_countries: count(c.id),
        active_countries: filter(count(c.id), c.covenant_status == "active"),
        total_gdp: sum(c.gdp_usd),
        total_fund: sum(c.contribution_usd)
      }
    )

    stats || %{
      total_countries: 0,
      active_countries: 0,
      total_gdp: 0,
      total_fund: 0
    }
  end
end
