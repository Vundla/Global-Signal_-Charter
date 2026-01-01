defmodule GlobalSovereign.Schema.EnergyProject do
  @moduledoc """
  Renewable energy project schema with resilience reserves.
  "Energy empowers, with 20% reserved for resilience."
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "energy_projects" do
    field :country_code, :string
    field :project_name, :string
    field :source_type, :string
    field :capacity_mw, :integer
    field :uptime_percent, :decimal
    field :profit_usd, :integer
    field :resilience_reserve_usd, :integer
    field :status, :string, default: "active"

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:country_code, :project_name, :source_type, :capacity_mw, :uptime_percent, :profit_usd, :resilience_reserve_usd, :status])
    |> validate_required([:country_code, :project_name, :source_type])
    |> validate_length(:country_code, is: 3)
    |> validate_number(:uptime_percent, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> foreign_key_constraint(:country_code)
    |> calculate_resilience_reserve()
  end

  defp calculate_resilience_reserve(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :profit_usd) do
      nil -> changeset
      profit when is_integer(profit) ->
        put_change(changeset, :resilience_reserve_usd, div(profit, 5)) # 20%
    end
  end
  defp calculate_resilience_reserve(changeset), do: changeset
end
