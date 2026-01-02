defmodule GlobalSovereignWeb.Resolvers.Phase4 do
  @moduledoc """
  Phase 4: GraphQL Resolvers for Countries and Projects
  """
  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.{Phase4Country, Phase4Project}
  import Ecto.Query

  # ==================== COUNTRY QUERIES ====================

  @doc """
  List all countries with optional filtering
  """
  def list_countries(_parent, args, _resolution) do
    query = from(c in Phase4Country, order_by: [desc: c.gdp_usd])

    query =
      case args do
        %{filter: %{region: region}} ->
          where(query, [c], c.region == ^region)

        %{filter: %{covenant_status: status}} ->
          where(query, [c], c.covenant_status == ^status)

        %{filter: %{min_gdp: min_gdp}} ->
          where(query, [c], c.gdp_usd >= ^min_gdp)

        _ ->
          query
      end

    {:ok, Repo.all(query)}
  end

  @doc """
  Get a single country by ID
  """
  def get_country(_parent, %{id: id}, _resolution) do
    case Repo.get(Phase4Country, id) do
      nil -> {:error, "Country not found"}
      country -> {:ok, country}
    end
  end

  @doc """
  Get a country by country code
  """
  def get_country_by_code(_parent, %{code: code}, _resolution) do
    case Repo.get_by(Phase4Country, country_code: code) do
      nil -> {:error, "Country not found"}
      country -> {:ok, country}
    end
  end

  @doc """
  Get regional statistics
  """
  def get_regional_stats(_parent, %{region: region}, _resolution) do
    stats = GlobalSovereign.GlobalExpansion.region_stats(region)
    {:ok, Map.put(stats, :region, region)}
  end

  @doc """
  Get global covenant statistics
  """
  def get_global_stats(_parent, _args, _resolution) do
    stats = GlobalSovereign.GlobalExpansion.global_covenant_stats()
    {:ok, stats}
  end

  # ==================== PROJECT QUERIES ====================

  @doc """
  List all projects with optional filtering
  """
  def list_projects(_parent, args, _resolution) do
    query = from(p in Phase4Project, order_by: [desc: p.budget_usd])

    query =
      case args do
        %{filter: %{sector: sector}} ->
          where(query, [p], p.sector == ^sector)

        %{filter: %{status: status}} ->
          where(query, [p], p.status == ^status)

        %{filter: %{country_id: country_id}} ->
          where(query, [p], p.country_id == ^country_id)

        %{filter: %{min_budget: min_budget}} ->
          where(query, [p], p.budget_usd >= ^min_budget)

        _ ->
          query
      end

    {:ok, Repo.all(query)}
  end

  @doc """
  Get a single project by ID
  """
  def get_project(_parent, %{id: id}, _resolution) do
    case Repo.get(Phase4Project, id) do
      nil -> {:error, "Project not found"}
      project -> {:ok, project}
    end
  end

  @doc """
  Get sectoral statistics
  """
  def get_sectoral_stats(_parent, _args, _resolution) do
    query = """
    SELECT 
      sector,
      COUNT(*)::integer as project_count,
      SUM(budget_usd)::bigint as total_budget,
      AVG(budget_usd)::float as avg_budget,
      AVG(impact_score)::float as avg_impact,
      COUNT(DISTINCT country_id)::integer as countries_involved
    FROM projects_phase4
    WHERE status = 'active'
    GROUP BY sector
    """

    case Repo.query(query) do
      {:ok, %{rows: rows, columns: columns}} ->
        stats =
          Enum.map(rows, fn row ->
            columns
            |> Enum.zip(row)
            |> Enum.into(%{})
          end)

        {:ok, stats}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # ==================== MUTATIONS ====================

  @doc """
  Create a new country
  """
  def create_country(_parent, %{input: attrs}, _resolution) do
    %Phase4Country{}
    |> Phase4Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an existing country
  """
  def update_country(_parent, %{id: id, input: attrs}, _resolution) do
    case Repo.get(Phase4Country, id) do
      nil ->
        {:error, "Country not found"}

      country ->
        country
        |> Phase4Country.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Create a new project
  """
  def create_project(_parent, %{input: attrs}, _resolution) do
    %Phase4Project{}
    |> Phase4Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an existing project
  """
  def update_project(_parent, %{id: id, input: attrs}, _resolution) do
    case Repo.get(Phase4Project, id) do
      nil ->
        {:error, "Project not found"}

      project ->
        project
        |> Phase4Project.changeset(attrs)
        |> Repo.update()
    end
  end
end
