defmodule GlobalSovereign.Schema.EducationProject do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "education_projects" do
    field :country_code, :string
    field :project_name, :string
    field :education_level, :string
    field :students_reached, :integer
    field :teachers_trained, :integer
    field :schools_built, :integer
    field :annual_budget_usd, :integer
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(education_project, attrs) do
    education_project
    |> cast(attrs, [:country_code, :project_name, :education_level, :students_reached, :teachers_trained, :schools_built, :annual_budget_usd, :status])
    |> validate_required([:country_code, :project_name, :education_level, :students_reached, :annual_budget_usd])
    |> validate_length(:country_code, is: 3)
    |> validate_inclusion(:education_level, ["primary", "secondary", "tertiary", "vocational"])
    |> validate_inclusion(:status, ["active", "paused", "completed"])
  end
end
