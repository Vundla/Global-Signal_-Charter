defmodule GlobalSovereignWeb.Schema do
  @moduledoc """
  Main GraphQL Schema for Global Sovereign Covenant
  """
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types GlobalSovereignWeb.Schema.Phase4Types

  alias GlobalSovereignWeb.Resolvers

  query do
    @desc "Get all countries with optional filtering"
    field :countries, list_of(:country) do
      arg :filter, :country_filter
      resolve &Resolvers.Phase4.list_countries/3
    end

    @desc "Get a specific country by ID"
    field :country, :country do
      arg :id, non_null(:id)
      resolve &Resolvers.Phase4.get_country/3
    end

    @desc "Get a country by country code"
    field :country_by_code, :country do
      arg :code, non_null(:string)
      resolve &Resolvers.Phase4.get_country_by_code/3
    end

    @desc "Get regional covenant statistics"
    field :regional_stats, :regional_stats do
      arg :region, non_null(:string)
      resolve &Resolvers.Phase4.get_regional_stats/3
    end

    @desc "Get global covenant statistics"
    field :global_stats, :global_stats do
      resolve &Resolvers.Phase4.get_global_stats/3
    end

    @desc "Get all projects with optional filtering"
    field :projects, list_of(:project) do
      arg :filter, :project_filter
      resolve &Resolvers.Phase4.list_projects/3
    end

    @desc "Get a specific project by ID"
    field :project, :project do
      arg :id, non_null(:id)
      resolve &Resolvers.Phase4.get_project/3
    end

    @desc "Get sectoral project statistics"
    field :sectoral_stats, list_of(:sectoral_stats) do
      resolve &Resolvers.Phase4.get_sectoral_stats/3
    end
  end

  mutation do
    @desc "Create a new country"
    field :create_country, :country do
      arg :input, non_null(:country_input)
      resolve &Resolvers.Phase4.create_country/3
    end

    @desc "Update an existing country"
    field :update_country, :country do
      arg :id, non_null(:id)
      arg :input, non_null(:country_input)
      resolve &Resolvers.Phase4.update_country/3
    end

    @desc "Create a new project"
    field :create_project, :project do
      arg :input, non_null(:project_input)
      resolve &Resolvers.Phase4.create_project/3
    end

    @desc "Update an existing project"
    field :update_project, :project do
      arg :id, non_null(:id)
      arg :input, non_null(:project_input)
      resolve &Resolvers.Phase4.update_project/3
    end
  end
end
