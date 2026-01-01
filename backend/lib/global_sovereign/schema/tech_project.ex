defmodule GlobalSovereign.Schema.TechProject do
  @moduledoc """
  Technology and connectivity project schema.
  "Technology connects, with offline-first capability."
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tech_projects" do
    field :country_code, :string
    field :project_name, :string
    field :sector, :string
    field :offline_capability, :boolean, default: true
    field :users_served, :integer
    field :contribution_usd, :integer
    field :status, :string, default: "active"

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:country_code, :project_name, :sector, :offline_capability, :users_served, :contribution_usd, :status])
    |> validate_required([:country_code, :project_name])
    |> validate_length(:country_code, is: 3)
    |> validate_inclusion(:sector, ["education", "health", "fintech", "connectivity"])
    |> foreign_key_constraint(:country_code)
  end
end
