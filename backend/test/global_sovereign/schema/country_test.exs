defmodule GlobalSovereign.Schema.CountryTest do
  use GlobalSovereign.DataCase, async: true

  alias GlobalSovereign.Schema.Country

  describe "changeset/2" do
    @valid_attrs %{
      code: "USA",
      name: "United States",
      gdp_usd: 27_360_000_000_000,
      contribution_usd: 2_736_000_000,
      covenant_status: "active"
    }

    test "valid changeset with all required fields" do
      changeset = Country.changeset(%Country{}, @valid_attrs)
      assert changeset.valid?
    end

    test "requires code" do
      attrs = Map.delete(@valid_attrs, :code)
      changeset = Country.changeset(%Country{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).code
    end

    test "requires name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = Country.changeset(%Country{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "validates code is exactly 3 characters" do
      invalid = %{@valid_attrs | code: "US"}
      changeset = Country.changeset(%Country{}, invalid)
      refute changeset.valid?
      assert "should be 3 character(s)" in errors_on(changeset).code
    end

    test "validates gdp_usd is greater than 0" do
      invalid = %{@valid_attrs | gdp_usd: 0}
      changeset = Country.changeset(%Country{}, invalid)
      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).gdp_usd
    end
  end

  describe "calculate_contribution/1" do
    test "calculates 0.01% of GDP correctly" do
      gdp = 1_000_000_000_000  # $1 trillion
      expected = 100_000_000   # $100 million (0.01%)

      assert Country.calculate_contribution(gdp) == expected
    end

    test "handles large GDP values" do
      gdp = 27_360_000_000_000  # US GDP
      expected = 2_736_000_000  # $2.736 billion

      assert Country.calculate_contribution(gdp) == expected
    end

    test "handles small GDP values" do
      gdp = 50_000_000_000  # $50 billion
      expected = 5_000_000  # $5 million

      assert Country.calculate_contribution(gdp) == expected
    end
  end
end
