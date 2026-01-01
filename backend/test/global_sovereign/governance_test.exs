defmodule GlobalSovereign.GovernanceTest do
  use GlobalSovereign.DataCase

  alias GlobalSovereign.Governance
  alias GlobalSovereign.Schema.Country

  describe "countries" do
    @valid_attrs %{
      name: "Test Country",
      code: "TST",
      gdp_usd: 1_000_000_000_000,
      covenant_status: "active"
    }
    @update_attrs %{
      name: "Updated Country",
      gdp_usd: 1_500_000_000_000,
      covenant_status: "suspended"
    }
    @invalid_attrs %{name: nil, code: nil}

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      countries = Governance.list_countries()
      assert length(countries) >= 1
      assert Enum.any?(countries, fn c -> c.id == country.id end)
    end

    test "list_active_countries/0 returns only active countries" do
      _inactive = country_fixture(%{covenant_status: "pending"})
      active = country_fixture(%{code: "ACT", covenant_status: "active"})
      
      active_countries = Governance.list_active_countries()
      assert Enum.any?(active_countries, fn c -> c.id == active.id end)
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      fetched = Governance.get_country!(country.id)
      assert fetched.id == country.id
      assert fetched.name == country.name
    end

    test "get_country_by_code/1 returns the country with given code" do
      country = country_fixture()
      fetched = Governance.get_country_by_code(country.code)
      assert fetched.id == country.id
      assert fetched.code == country.code
    end

    test "create_country/1 with valid data creates a country" do
      assert {:ok, %Country{} = country} = Governance.create_country(@valid_attrs)
      assert country.name == "Test Country"
      assert country.code == "TST"
      assert country.gdp_usd == 1_000_000_000_000
      # Check that contribution is calculated (0.01% of GDP)
      assert country.contribution_usd == 100_000_000
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Governance.create_country(@invalid_attrs)
    end

    test "create_country/1 automatically calculates contribution" do
      attrs = %{
        name: "Auto Calc Country",
        code: "ACC",
        gdp_usd: 5_000_000_000_000
      }
      
      assert {:ok, %Country{} = country} = Governance.create_country(attrs)
      # 0.01% of 5 trillion = 500 million
      assert country.contribution_usd == 500_000_000
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      assert {:ok, %Country{} = updated} = Governance.update_country(country, @update_attrs)
      assert updated.name == "Updated Country"
      assert updated.gdp_usd == 1_500_000_000_000
      assert updated.covenant_status == "suspended"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = Governance.update_country(country, @invalid_attrs)
      fetched = Governance.get_country!(country.id)
      assert fetched.name == country.name
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = Governance.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> Governance.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = Governance.change_country(country)
    end

    test "calculate_total_fund/0 sums active country contributions" do
      # Create active countries
      country_fixture(%{code: "AA1", gdp_usd: 1_000_000_000_000, covenant_status: "active"})
      country_fixture(%{code: "AA2", gdp_usd: 2_000_000_000_000, covenant_status: "active"})
      # Create pending country (should not be counted)
      country_fixture(%{code: "AA3", gdp_usd: 1_000_000_000_000, covenant_status: "pending"})
      
      total = Governance.calculate_total_fund()
      # 0.01% of (1T + 2T) = 300M
      assert total >= 300_000_000
    end

    test "covenant_stats/0 returns correct statistics" do
      country_fixture(%{code: "ST1", gdp_usd: 1_000_000_000_000, covenant_status: "active"})
      country_fixture(%{code: "ST2", gdp_usd: 2_000_000_000_000, covenant_status: "pending"})
      
      stats = Governance.covenant_stats()
      
      assert stats.total_countries >= 2
      assert stats.active_countries >= 1
      assert stats.total_gdp >= 3_000_000_000_000
      assert stats.total_fund >= 100_000_000
    end
  end

  defp country_fixture(attrs \\ %{}) do
    default_attrs = %{
      name: "Fixture Country",
      code: "FIX",
      gdp_usd: 500_000_000_000,
      covenant_status: "active"
    }

    {:ok, country} =
      attrs
      |> Enum.into(default_attrs)
      |> Governance.create_country()

    country
  end
end
