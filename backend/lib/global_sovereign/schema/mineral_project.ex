defmodule GlobalSovereign.Schema.MineralProject do
  @moduledoc """
  Mineral extraction project schema with transparent profit-sharing.
  "Minerals sustain, with 50% to communities, 30% to covenant."
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mineral_projects" do
    field :country_code, :string
    field :resource_type, :string
    field :extraction_volume, :integer
    field :profit_usd, :integer
    field :local_reinvestment_usd, :integer
    field :global_contribution_usd, :integer
    field :status, :string, default: "active"

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:country_code, :resource_type, :extraction_volume, :profit_usd, :local_reinvestment_usd, :global_contribution_usd, :status])
    |> validate_required([:country_code, :resource_type])
    |> validate_length(:country_code, is: 3)
    |> foreign_key_constraint(:country_code)
    |> calculate_distribution()
  end

  defp calculate_distribution(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :profit_usd) do
      nil -> changeset
      profit when is_integer(profit) ->
        changeset
        |> put_change(:local_reinvestment_usd, div(profit, 2)) # 50%
        |> put_change(:global_contribution_usd, div(profit * 3, 10)) # 30%
    end
  end
  defp calculate_distribution(changeset), do: changeset
end
