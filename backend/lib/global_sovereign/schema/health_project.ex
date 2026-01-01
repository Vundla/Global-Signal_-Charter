defmodule GlobalSovereign.Schema.HealthProject do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "health_projects" do
    field :country_code, :string
    field :project_name, :string
    field :health_type, :string
    field :beneficiaries, :integer
    field :facilities_count, :integer
    field :annual_budget_usd, :integer
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(health_project, attrs) do
    health_project
    |> cast(attrs, [:country_code, :project_name, :health_type, :beneficiaries, :facilities_count, :annual_budget_usd, :status])
    |> validate_required([:country_code, :project_name, :health_type, :beneficiaries, :annual_budget_usd])
    |> validate_length(:country_code, is: 3)
    |> validate_inclusion(:status, ["active", "paused", "completed"])
  end
end
