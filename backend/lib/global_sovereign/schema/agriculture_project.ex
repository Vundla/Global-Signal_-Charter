defmodule GlobalSovereign.Schema.AgricultureProject do
  @moduledoc """
  Agriculture project schema for tracking food security initiatives.
  "Agriculture feeds the covenant."
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agriculture_projects" do
    field :country_code, :string
    field :project_name, :string
    field :crop_type, :string
    field :yield_estimate, :integer
    field :irrigation_method, :string
    field :contribution_usd, :integer
    field :status, :string, default: "active"

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:country_code, :project_name, :crop_type, :yield_estimate, :irrigation_method, :contribution_usd, :status])
    |> validate_required([:country_code, :project_name])
    |> validate_length(:country_code, is: 3)
    |> foreign_key_constraint(:country_code)
  end
end
