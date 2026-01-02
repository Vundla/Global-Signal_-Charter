defmodule GlobalSovereign.Schema.Phase4Project do
  @moduledoc """
  Phase 4 schema for projects funded by the Global Sovereign covenant.
  
  Target: 500+ projects across 6 key sectors.
  This schema maps to the projects_phase4 table.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias GlobalSovereign.Schema.Phase4Country

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects_phase4" do
    field :project_name, :string
    field :sector, :string
    field :status, :string, default: "active"
    field :budget_usd, :integer
    field :impact_score, :decimal
    field :description, :string

    belongs_to :country, Phase4Country

    timestamps()
  end

  @valid_sectors ~w(Technology Healthcare Energy Agriculture Education Infrastructure)
  @valid_statuses ~w(planning active completed cancelled)

  @doc """
  Changeset for creating or updating a Phase 4 project.
  """
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:project_name, :sector, :status, :budget_usd, :impact_score, :description, :country_id])
    |> validate_required([:project_name, :sector, :country_id])
    |> validate_inclusion(:sector, @valid_sectors)
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:budget_usd, greater_than: 0)
    |> validate_number(:impact_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 10)
    |> foreign_key_constraint(:country_id)
  end
end
