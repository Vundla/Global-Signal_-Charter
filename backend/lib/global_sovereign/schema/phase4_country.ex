defmodule GlobalSovereign.Schema.Phase4Country do
  @moduledoc """
  Phase 4 schema for countries participating in the Global Sovereign covenant.
  
  Each country contributes 0.01% of GDP annually to the shared fund.
  This schema maps to the countries_phase4 table for Phase 4 expansion.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias GlobalSovereign.Schema.Phase4Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "countries_phase4" do
    field :country_code, :string
    field :country_name, :string
    field :region, :string
    field :gdp_usd, :integer
    field :contribution_usd, :integer
    field :covenant_status, :string, default: "active"
    field :joined_at, :utc_datetime
    field :last_synced_at, :utc_datetime

    has_many :projects, Phase4Project, foreign_key: :country_id

    timestamps()
  end

  @valid_regions ~w(APAC EMEA Americas)
  @valid_statuses ~w(pending active suspended)

  @doc """
  Changeset for creating or updating a Phase 4 country.
  """
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:country_code, :country_name, :region, :gdp_usd, :contribution_usd, :covenant_status, :joined_at, :last_synced_at])
    |> validate_required([:country_code, :country_name, :region, :gdp_usd])
    |> validate_length(:country_code, min: 2, max: 3)
    |> validate_inclusion(:region, @valid_regions)
    |> validate_inclusion(:covenant_status, @valid_statuses)
    |> validate_number(:gdp_usd, greater_than: 0)
    |> unique_constraint(:country_code)
    |> calculate_contribution()
  end

  @doc """
  Calculates contribution as 0.01% of GDP.
  """
  def calculate_contribution(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :gdp_usd) do
      nil -> 
        changeset
      gdp ->
        contribution = div(gdp, 10000)
        put_change(changeset, :contribution_usd, contribution)
    end
  end

  def calculate_contribution(changeset), do: changeset
end
