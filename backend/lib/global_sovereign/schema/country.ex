defmodule GlobalSovereign.Schema.Country do
  @moduledoc """
  Schema for countries participating in the Global Sovereign covenant.
  
  Each country contributes 0.01% of GDP annually to the shared fund.
  Profit distribution: 50% communities, 30% nations, 20% infrastructure.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "countries" do
    field :name, :string
    field :code, :string
    field :gdp_usd, :integer
    field :contribution_usd, :integer
    field :covenant_status, :string, default: "pending"
    field :joined_at, :utc_datetime

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  @doc """
  Changeset for creating or updating a country.
  
  ## Examples
      
      iex> changeset(%Country{}, %{name: "South Africa", code: "ZAF", gdp_usd: Decimal.new("405000000000")})
      %Ecto.Changeset{valid?: true}
  """
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :code, :gdp_usd, :contribution_usd, :covenant_status, :joined_at])
    |> validate_required([:name, :code])
    |> validate_length(:code, is: 3)
    |> validate_number(:gdp_usd, greater_than: 0)
    |> unique_constraint(:code)
    |> calculate_contribution()
  end

  @doc """
  Calculates contribution as 0.01% of GDP.
  """
  def calculate_contribution(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :gdp_usd) do
      nil -> 
        changeset
      gdp when is_integer(gdp) ->
        contribution = div(gdp, 10000)
        put_change(changeset, :contribution_usd, contribution)
    end
  end

  def calculate_contribution(changeset), do: changeset
end
