defmodule GlobalSovereign.Schema.ProjectTest do
  use GlobalSovereign.DataCase, async: false  # Changed to false to avoid unique constraint issues

  alias GlobalSovereign.Schema.{Country, Project}

  setup do
    # Clean before each test to avoid unique constraint violations
    # Delete in correct order due to foreign keys
    Repo.delete_all(Project)
    Repo.query!("DELETE FROM agriculture_projects")
    Repo.query!("DELETE FROM energy_projects")
    Repo.query!("DELETE FROM mineral_projects")
    Repo.query!("DELETE FROM tech_projects")
    Repo.query!("DELETE FROM health_projects")
    Repo.query!("DELETE FROM education_projects")
    Repo.delete_all(Country)
    
    country =
      %Country{}
      |> Country.changeset(%{
        code: "USA",
        name: "United States",
        gdp_usd: 27_360_000_000_000,
        contribution_usd: 2_736_000_000
      })
      |> Repo.insert!()

    {:ok, country: country}
  end

  describe "changeset/2" do
    test "valid changeset with all required fields", %{country: country} do
      attrs = %{
        project_name: "Green Energy Initiative",
        sector: "Energy",
        budget_usd: 100_000_000,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
    end

    test "requires project_name", %{country: country} do
      attrs = %{
        sector: "Energy",
        budget_usd: 100_000_000,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).project_name
    end

    test "requires sector", %{country: country} do
      attrs = %{
        project_name: "Test Project",
        budget_usd: 100_000_000,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).sector
    end

    test "validates sector is one of allowed values", %{country: country} do
      attrs = %{
        project_name: "Test Project",
        sector: "InvalidSector",
        budget_usd: 100_000_000,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).sector
    end

    test "validates status is one of allowed values", %{country: country} do
      attrs = %{
        project_name: "Test Project",
        sector: "Energy",
        status: "InvalidStatus",
        budget_usd: 100_000_000,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).status
    end

    test "validates budget_usd is greater than 0", %{country: country} do
      attrs = %{
        project_name: "Test Project",
        sector: "Energy",
        budget_usd: 0,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).budget_usd
    end

    test "validates impact_score is between 0 and 10", %{country: country} do
      invalid_high = %{
        project_name: "Test Project",
        sector: "Energy",
        budget_usd: 100_000_000,
        impact_score: 11.0,
        country_id: country.id
      }

      changeset = Project.changeset(%Project{}, invalid_high)
      refute changeset.valid?
      assert "must be less than or equal to 10.0" in errors_on(changeset).impact_score
    end
  end
end
