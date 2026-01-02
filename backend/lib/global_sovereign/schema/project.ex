defmodule GlobalSovereign.Schema.Project do
  @moduledoc """
  Phase 4: Project Schema
  Represents covenant-funded projects (500+ in Phase 4)
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects_phase4" do
    field :project_name, :string
    field :sector, :string
    field :status, :string, default: "active"
    field :budget_usd, :integer
    field :impact_score, :float
    field :description, :string

    belongs_to :country, GlobalSovereign.Schema.Country

    timestamps()
  end

  @doc """
  Changeset for creating/updating a project
  """
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :project_name,
      :sector,
      :status,
      :budget_usd,
      :impact_score,
      :description,
      :country_id
    ])
    |> validate_required([
      :project_name,
      :sector,
      :budget_usd,
      :country_id
    ])
    |> validate_inclusion(:sector, [
      "Technology",
      "Healthcare",
      "Energy",
      "Agriculture",
      "Education",
      "Infrastructure"
    ])
    |> validate_inclusion(:status, ["active", "completed", "pending", "cancelled"])
    |> validate_number(:budget_usd, greater_than: 0)
    |> validate_number(:impact_score, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 10.0)
    |> foreign_key_constraint(:country_id)
  end
end
