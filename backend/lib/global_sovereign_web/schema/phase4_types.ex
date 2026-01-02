defmodule GlobalSovereignWeb.Schema.Phase4Types do
  @moduledoc """
  Phase 4: GraphQL Types for Countries and Projects
  """
  use Absinthe.Schema.Notation

  @desc "A country participating in the Global Covenant"
  object :country do
    field :id, non_null(:id)
    field :country_code, non_null(:string)
    field :country_name, non_null(:string)
    field :region, non_null(:string)
    field :gdp_usd, non_null(:integer)
    field :contribution_usd, non_null(:integer)
    field :covenant_status, non_null(:string)
    field :joined_at, :datetime
    field :last_synced_at, :datetime
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    field :projects, list_of(:project) do
      resolve fn country, _, _ ->
        {:ok, GlobalSovereign.Repo.preload(country, :projects).projects}
      end
    end
  end

  @desc "A covenant-funded project"
  object :project do
    field :id, non_null(:id)
    field :project_name, non_null(:string)
    field :sector, non_null(:string)
    field :status, non_null(:string)
    field :budget_usd, non_null(:integer)
    field :impact_score, :float
    field :description, :string
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    field :country, :country do
      resolve fn project, _, _ ->
        {:ok, GlobalSovereign.Repo.preload(project, :country).country}
      end
    end
  end

  @desc "Regional statistics"
  object :regional_stats do
    field :region, non_null(:string)
    field :count, non_null(:integer)
    field :total_gdp, non_null(:integer)
    field :total_covenant, non_null(:integer)
    field :active_countries, non_null(:integer)
  end

  @desc "Global covenant statistics"
  object :global_stats do
    field :total_countries, non_null(:integer)
    field :total_gdp, non_null(:integer)
    field :total_covenant_fund, non_null(:integer)
    field :active_countries, non_null(:integer)
  end

  @desc "Sectoral project statistics"
  object :sectoral_stats do
    field :sector, non_null(:string)
    field :project_count, non_null(:integer)
    field :total_budget, non_null(:integer)
    field :avg_budget, :float
    field :avg_impact, :float
    field :countries_involved, non_null(:integer)
  end

  input_object :country_filter do
    field :region, :string
    field :covenant_status, :string
    field :min_gdp, :integer
  end

  input_object :project_filter do
    field :sector, :string
    field :status, :string
    field :country_id, :id
    field :min_budget, :integer
  end

  input_object :country_input do
    field :country_code, non_null(:string)
    field :country_name, non_null(:string)
    field :region, non_null(:string)
    field :gdp_usd, non_null(:integer)
    field :contribution_usd, non_null(:integer)
    field :covenant_status, :string
    field :joined_at, :datetime
  end

  input_object :project_input do
    field :project_name, non_null(:string)
    field :sector, non_null(:string)
    field :status, :string
    field :budget_usd, non_null(:integer)
    field :impact_score, :float
    field :description, :string
    field :country_id, non_null(:id)
  end
end
