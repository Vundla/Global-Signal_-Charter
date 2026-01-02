defmodule GlobalSovereign.Repo.Migrations.Phase4CountriesAndProjects do
  use Ecto.Migration

  def up do
    # Drop any existing views first
    execute "DROP VIEW IF EXISTS covenant_sectoral_stats CASCADE"
    execute "DROP VIEW IF EXISTS covenant_global_stats CASCADE"
    execute "DROP VIEW IF EXISTS covenant_regional_stats CASCADE"

    # Create countries table
    create table(:countries_phase4, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :country_code, :string, size: 3, null: false
      add :country_name, :string, size: 100, null: false
      add :region, :string, size: 20, null: false
      add :gdp_usd, :bigint, null: false
      add :contribution_usd, :bigint, null: false
      add :covenant_status, :string, size: 20, null: false, default: "active"
      add :joined_at, :utc_datetime
      add :last_synced_at, :utc_datetime

      timestamps()
    end

    create unique_index(:countries_phase4, [:country_code])
    create index(:countries_phase4, [:region])
    create index(:countries_phase4, [:covenant_status])
    create index(:countries_phase4, [:joined_at])

    # Create projects table
    create table(:projects_phase4, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :project_name, :string, size: 200, null: false
      add :sector, :string, size: 50, null: false
      add :status, :string, size: 20, null: false, default: "active"
      add :budget_usd, :bigint, null: false
      add :impact_score, :decimal, precision: 3, scale: 2
      add :description, :text
      add :country_id, references(:countries_phase4, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:projects_phase4, [:sector])
    create index(:projects_phase4, [:status])
    create index(:projects_phase4, [:country_id])
    create index(:projects_phase4, [:budget_usd])

    # Create views
    execute """
    CREATE OR REPLACE VIEW covenant_regional_stats AS
    SELECT 
      region,
      COUNT(*)::integer as country_count,
      SUM(gdp_usd)::bigint as total_gdp,
      SUM(contribution_usd)::bigint as total_covenant_contribution,
      AVG(gdp_usd)::bigint as avg_gdp,
      MAX(gdp_usd)::bigint as max_gdp,
      MIN(gdp_usd)::bigint as min_gdp
    FROM countries_phase4
    WHERE covenant_status = 'active'
    GROUP BY region
    """

    execute """
    CREATE OR REPLACE VIEW covenant_global_stats AS
    SELECT 
      COUNT(*)::integer as total_countries,
      SUM(gdp_usd)::bigint as global_gdp,
      SUM(contribution_usd)::bigint as global_covenant_fund,
      AVG(contribution_usd)::bigint as avg_contribution
    FROM countries_phase4
    WHERE covenant_status = 'active'
    """

    execute """
    CREATE OR REPLACE VIEW covenant_sectoral_stats AS
    SELECT 
      sector,
      COUNT(*)::integer as project_count,
      SUM(budget_usd)::bigint as total_budget,
      AVG(budget_usd)::bigint as avg_budget,
      AVG(impact_score)::float as avg_impact,
      COUNT(DISTINCT country_id)::integer as countries_involved
    FROM projects_phase4
    WHERE status = 'active'
    GROUP BY sector
    """
  end

  def down do
    execute "DROP VIEW IF EXISTS covenant_sectoral_stats"
    execute "DROP VIEW IF EXISTS covenant_global_stats"
    execute "DROP VIEW IF EXISTS covenant_regional_stats"
    drop table(:projects_phase4)
    drop table(:countries_phase4)
  end
end
