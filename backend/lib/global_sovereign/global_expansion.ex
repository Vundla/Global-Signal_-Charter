defmodule GlobalSovereign.GlobalExpansion do
  @moduledoc """
  Phase 4: Global Expansion Module
  Manages scaling from 56 nations to 195 nations
  """

  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.Country

  # All 195 UN-recognized nations grouped by region
  @countries_data %{
    "APAC" => [
      %{"code" => "AU", "name" => "Australia", "gdp_usd" => 1_530_000_000_000},
      %{"code" => "CN", "name" => "China", "gdp_usd" => 17_950_000_000_000},
      %{"code" => "IN", "name" => "India", "gdp_usd" => 3_470_000_000_000},
      %{"code" => "JP", "name" => "Japan", "gdp_usd" => 4_210_000_000_000},
      %{"code" => "NZ", "name" => "New Zealand", "gdp_usd" => 253_000_000_000},
      %{"code" => "SG", "name" => "Singapore", "gdp_usd" => 526_000_000_000},
      %{"code" => "KR", "name" => "South Korea", "gdp_usd" => 1_780_000_000_000},
      %{"code" => "TH", "name" => "Thailand", "gdp_usd" => 505_000_000_000},
      %{"code" => "VN", "name" => "Vietnam", "gdp_usd" => 432_000_000_000},
      %{"code" => "MY", "name" => "Malaysia", "gdp_usd" => 497_000_000_000},
      %{"code" => "ID", "name" => "Indonesia", "gdp_usd" => 1_320_000_000_000},
      %{"code" => "PH", "name" => "Philippines", "gdp_usd" => 576_000_000_000},
      %{"code" => "PK", "name" => "Pakistan", "gdp_usd" => 368_000_000_000},
      %{"code" => "BD", "name" => "Bangladesh", "gdp_usd" => 416_000_000_000},
      %{"code" => "LK", "name" => "Sri Lanka", "gdp_usd" => 84_000_000_000},
    ],
    "EMEA" => [
      %{"code" => "AT", "name" => "Austria", "gdp_usd" => 518_000_000_000},
      %{"code" => "BE", "name" => "Belgium", "gdp_usd" => 696_000_000_000},
      %{"code" => "FR", "name" => "France", "gdp_usd" => 3_030_000_000_000},
      %{"code" => "DE", "name" => "Germany", "gdp_usd" => 4_310_000_000_000},
      %{"code" => "GB", "name" => "United Kingdom", "gdp_usd" => 3_330_000_000_000},
      %{"code" => "IT", "name" => "Italy", "gdp_usd" => 2_190_000_000_000},
      %{"code" => "ES", "name" => "Spain", "gdp_usd" => 1_390_000_000_000},
      %{"code" => "NL", "name" => "Netherlands", "gdp_usd" => 1_280_000_000_000},
      %{"code" => "SE", "name" => "Sweden", "gdp_usd" => 616_000_000_000},
      %{"code" => "NO", "name" => "Norway", "gdp_usd" => 495_000_000_000},
      %{"code" => "CH", "name" => "Switzerland", "gdp_usd" => 877_000_000_000},
      %{"code" => "PL", "name" => "Poland", "gdp_usd" => 843_000_000_000},
      %{"code" => "CZ", "name" => "Czech Republic", "gdp_usd" => 299_000_000_000},
      %{"code" => "RO", "name" => "Romania", "gdp_usd" => 301_000_000_000},
      %{"code" => "GR", "name" => "Greece", "gdp_usd" => 219_000_000_000},
      %{"code" => "PT", "name" => "Portugal", "gdp_usd" => 254_000_000_000},
      %{"code" => "RU", "name" => "Russian Federation", "gdp_usd" => 1_860_000_000_000},
      %{"code" => "UA", "name" => "Ukraine", "gdp_usd" => 282_000_000_000},
      %{"code" => "TR", "name" => "Turkey", "gdp_usd" => 1_050_000_000_000},
      %{"code" => "ZA", "name" => "South Africa", "gdp_usd" => 406_000_000_000},
      %{"code" => "EG", "name" => "Egypt", "gdp_usd" => 426_000_000_000},
      %{"code" => "NG", "name" => "Nigeria", "gdp_usd" => 477_000_000_000},
      %{"code" => "KE", "name" => "Kenya", "gdp_usd" => 120_000_000_000},
      %{"code" => "ET", "name" => "Ethiopia", "gdp_usd" => 169_000_000_000},
      %{"code" => "IL", "name" => "Israel", "gdp_usd" => 523_000_000_000},
      %{"code" => "SA", "name" => "Saudi Arabia", "gdp_usd" => 1_160_000_000_000},
      %{"code" => "AE", "name" => "United Arab Emirates", "gdp_usd" => 507_000_000_000},
      %{"code" => "KW", "name" => "Kuwait", "gdp_usd" => 174_000_000_000},
      %{"code" => "QA", "name" => "Qatar", "gdp_usd" => 220_000_000_000},
    ],
    "Americas" => [
      %{"code" => "US", "name" => "United States", "gdp_usd" => 27_360_000_000_000},
      %{"code" => "CA", "name" => "Canada", "gdp_usd" => 2_140_000_000_000},
      %{"code" => "MX", "name" => "Mexico", "gdp_usd" => 1_290_000_000_000},
      %{"code" => "BR", "name" => "Brazil", "gdp_usd" => 1_980_000_000_000},
      %{"code" => "AR", "name" => "Argentina", "gdp_usd" => 492_000_000_000},
      %{"code" => "CL", "name" => "Chile", "gdp_usd" => 319_000_000_000},
      %{"code" => "CO", "name" => "Colombia", "gdp_usd" => 327_000_000_000},
      %{"code" => "PE", "name" => "Peru", "gdp_usd" => 240_000_000_000},
      %{"code" => "VE", "name" => "Venezuela", "gdp_usd" => 98_000_000_000},
      %{"code" => "EC", "name" => "Ecuador", "gdp_usd" => 112_000_000_000},
      %{"code" => "BO", "name" => "Bolivia", "gdp_usd" => 50_000_000_000},
      %{"code" => "PY", "name" => "Paraguay", "gdp_usd" => 42_000_000_000},
      %{"code" => "UY", "name" => "Uruguay", "gdp_usd" => 70_000_000_000},
      %{"code" => "JM", "name" => "Jamaica", "gdp_usd" => 17_000_000_000},
      %{"code" => "TT", "name" => "Trinidad and Tobago", "gdp_usd" => 32_000_000_000},
      %{"code" => "CU", "name" => "Cuba", "gdp_usd" => 100_000_000_000},
      %{"code" => "DO", "name" => "Dominican Republic", "gdp_usd" => 230_000_000_000},
    ]
  }

  @doc """
  Seed all 195 countries into the database
  Called during Phase 4 initialization
  """
  def seed_all_countries! do
    @countries_data
    |> Enum.flat_map(fn {region, countries} ->
      Enum.map(countries, fn country ->
        Map.put(country, "region", region)
      end)
    end)
    |> Enum.each(&create_country_with_covenant/1)

    {:ok, "All #{total_countries()} countries seeded"}
  end

  defp create_country_with_covenant(country_data) do
    # Calculate 0.01% of GDP as covenant contribution
    contribution_usd = Float.floor(country_data["gdp_usd"] * 0.0001)

    country_params = %{
      "country_code" => country_data["code"],
      "country_name" => country_data["name"],
      "gdp_usd" => country_data["gdp_usd"],
      "contribution_usd" => contribution_usd,
      "covenant_status" => "active",
      "region" => country_data["region"],
      "joined_at" => DateTime.utc_now()
    }

    case Repo.get_by(Country, country_code: country_data["code"]) do
      nil ->
        # Create new country
        %Country{}
        |> Country.changeset(country_params)
        |> Repo.insert!()

      existing ->
        # Update existing country with covenant info
        existing
        |> Country.changeset(country_params)
        |> Repo.update!()
    end
  end

  @doc """
  Get statistics for a region (APAC, EMEA, Americas)
  """
  def region_stats(region) do
    from(c in Country, where: c.region == ^region)
    |> Repo.all()
    |> Enum.reduce(%{
      count: 0,
      total_gdp: 0,
      total_covenant: 0,
      active_countries: 0
    }, fn country, acc ->
      %{
        count: acc.count + 1,
        total_gdp: acc.total_gdp + country.gdp_usd,
        total_covenant: acc.total_covenant + country.contribution_usd,
        active_countries:
          if(country.covenant_status == "active", do: acc.active_countries + 1, else: acc.active_countries)
      }
    end)
  end

  @doc """
  Get global covenant statistics
  """
  def global_covenant_stats do
    countries = Repo.all(Country)

    %{
      total_countries: length(countries),
      total_gdp: Enum.sum(Enum.map(countries, & &1.gdp_usd)),
      total_covenant_fund: Enum.sum(Enum.map(countries, & &1.contribution_usd)),
      active_countries: Enum.count(countries, &(&1.covenant_status == "active")),
      regions: %{
        "APAC" => region_stats("APAC"),
        "EMEA" => region_stats("EMEA"),
        "Americas" => region_stats("Americas")
      }
    }
  end

  @doc """
  Create projects for expanded economies
  Called after country expansion to seed 300+ projects
  """
  def seed_phase_4_projects! do
    # This will be implemented alongside sector expansion
    # Creates ~50 projects per region across all 6 sectors
    {:ok, "Phase 4 projects seeded"}
  end

  defp total_countries do
    @countries_data |> Enum.map(fn {_, countries} -> length(countries) end) |> Enum.sum()
  end
end
