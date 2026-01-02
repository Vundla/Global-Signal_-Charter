defmodule GlobalSovereignWeb.Resolvers.Phase4Test do
  use GlobalSovereign.DataCase, async: false  # Changed from async: true to avoid data conflicts

  alias GlobalSovereign.Schema.{Phase4Country, Phase4Project}
  alias GlobalSovereignWeb.Resolvers.Phase4

  setup do
    # Clean tables before each test
    Repo.delete_all(Phase4Project)
    Repo.delete_all(Phase4Country)

    # Create test countries with unique 2-letter codes to avoid conflicts
    {:ok, usa} =
      %Phase4Country{}
      |> Phase4Country.changeset(%{
        country_code: "T1",
        country_name: "Test United States",
        region: "Americas",
        gdp_usd: 27_360_000_000_000,
        contribution_usd: 2_736_000_000,
        covenant_status: "active"
      })
      |> Repo.insert()

    {:ok, china} =
      %Phase4Country{}
      |> Phase4Country.changeset(%{
        country_code: "T2",
        country_name: "Test China",
        region: "APAC",
        gdp_usd: 17_950_000_000_000,
        contribution_usd: 1_795_000_000,
        covenant_status: "active"
      })
      |> Repo.insert()

    # Create test projects
    {:ok, project1} =
      %Phase4Project{}
      |> Phase4Project.changeset(%{
        project_name: "Green Energy USA",
        sector: "Energy",
        budget_usd: 500_000_000,
        impact_score: Decimal.new("8.5"),
        country_id: usa.id
      })
      |> Repo.insert()

    {:ok, project2} =
      %Phase4Project{}
      |> Phase4Project.changeset(%{
        project_name: "Digital China",
        sector: "Technology",
        budget_usd: 1_000_000_000,
        impact_score: Decimal.new("9.2"),
        country_id: china.id
      })
      |> Repo.insert()

    {:ok, usa: usa, china: china, project1: project1, project2: project2}
  end

  describe "list_countries/3" do
    test "returns all countries without filter", %{usa: usa, china: china} do
      {:ok, countries} = Phase4.list_countries(nil, %{}, nil)

      assert length(countries) == 2
      country_codes = Enum.map(countries, & &1.country_code)
      assert "T1" in country_codes
      assert "T2" in country_codes
    end

    test "filters by region", %{usa: usa} do
      {:ok, countries} = Phase4.list_countries(nil, %{filter: %{region: "Americas"}}, nil)

      assert length(countries) == 1
      assert hd(countries).country_code == "T1"
    end

    test "filters by covenant_status", %{usa: usa, china: china} do
      {:ok, countries} = Phase4.list_countries(nil, %{filter: %{covenant_status: "active"}}, nil)

      assert length(countries) == 2
    end
  end

  describe "get_country/3" do
    test "returns country by ID", %{usa: usa} do
      {:ok, country} = Phase4.get_country(nil, %{id: usa.id}, nil)

      assert country.id == usa.id
      assert country.country_name == "Test United States"
    end

    test "returns error for non-existent ID" do
      fake_id = Ecto.UUID.generate()
      {:error, message} = Phase4.get_country(nil, %{id: fake_id}, nil)

      assert message == "Country not found"
    end
  end

  describe "get_country_by_code/3" do
    test "returns country by code", %{usa: usa} do
      {:ok, country} = Phase4.get_country_by_code(nil, %{code: "T1"}, nil)

      assert country.id == usa.id
      assert country.country_name == "Test United States"
    end

    test "returns error for non-existent code" do
      {:error, message} = Phase4.get_country_by_code(nil, %{code: "XYZ"}, nil)

      assert message == "Country not found"
    end
  end

  describe "list_projects/3" do
    test "returns all projects without filter", %{project1: p1, project2: p2} do
      {:ok, projects} = Phase4.list_projects(nil, %{}, nil)

      assert length(projects) == 2
      project_ids = Enum.map(projects, & &1.id)
      assert p1.id in project_ids
      assert p2.id in project_ids
    end

    test "filters by sector", %{project1: p1} do
      {:ok, projects} = Phase4.list_projects(nil, %{filter: %{sector: "Energy"}}, nil)

      assert length(projects) == 1
      assert hd(projects).id == p1.id
    end

    test "filters by country_id", %{usa: usa, project1: p1} do
      {:ok, projects} = Phase4.list_projects(nil, %{filter: %{country_id: usa.id}}, nil)

      assert length(projects) == 1
      assert hd(projects).id == p1.id
    end
  end

  describe "create_country/3" do
    test "creates a country with valid attributes" do
      attrs = %{
        country_code: "GBR",
        country_name: "United Kingdom",
        region: "EMEA",
        gdp_usd: 3_330_000_000_000,
        contribution_usd: 333_000_000,
        covenant_status: "active"
      }

      {:ok, country} = Phase4.create_country(nil, %{input: attrs}, nil)

      assert country.country_code == "GBR"
      assert country.country_name == "United Kingdom"
    end

    test "returns error with invalid attributes" do
      attrs = %{
        country_code: "U",  # Too short
        country_name: "United Kingdom",
        region: "INVALID",  # Not in allowed regions
        gdp_usd: -10  # Invalid GDP
      }

      {:error, changeset} = Phase4.create_country(nil, %{input: attrs}, nil)

      assert changeset.errors[:country_code]
    end
  end

  describe "create_project/3" do
    test "creates a project with valid attributes", %{usa: usa} do
      attrs = %{
        project_name: "Healthcare Initiative",
        sector: "Healthcare",
        budget_usd: 250_000_000,
        impact_score: 7.8,
        country_id: usa.id
      }

      {:ok, project} = Phase4.create_project(nil, %{input: attrs}, nil)

      assert project.project_name == "Healthcare Initiative"
      assert project.sector == "Healthcare"
    end

    test "returns error with invalid sector", %{usa: usa} do
      attrs = %{
        project_name: "Test Project",
        sector: "InvalidSector",
        budget_usd: 100_000_000,
        country_id: usa.id
      }

      {:error, changeset} = Phase4.create_project(nil, %{input: attrs}, nil)

      assert changeset.errors[:sector]
    end
  end
end
