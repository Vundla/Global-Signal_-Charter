defmodule GlobalSovereign.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :role, :string, default: "viewer", null: false
      add :is_active, :boolean, default: true

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
