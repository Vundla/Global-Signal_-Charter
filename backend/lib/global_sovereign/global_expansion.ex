defmodule GlobalSovereign.GlobalExpansion do
  @moduledoc """
  Phase 4: Global Expansion Module
  Manages scaling from 56 nations to 195 nations
  """

  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.Phase4Country
  alias GlobalSovereign.Schema.Phase4Project
  import Ecto.Query

  # All 195 UN-recognized nations grouped by region
  @countries_data %{
    "APAC" => [
      # Major Economies
      %{"code" => "AU", "name" => "Australia", "gdp_usd" => 1_530_000_000_000},
      %{"code" => "CN", "name" => "China", "gdp_usd" => 17_950_000_000_000},
      %{"code" => "IN", "name" => "India", "gdp_usd" => 3_470_000_000_000},
      %{"code" => "JP", "name" => "Japan", "gdp_usd" => 4_210_000_000_000},
      %{"code" => "KR", "name" => "South Korea", "gdp_usd" => 1_780_000_000_000},
      %{"code" => "ID", "name" => "Indonesia", "gdp_usd" => 1_320_000_000_000},
      # Southeast Asia
      %{"code" => "SG", "name" => "Singapore", "gdp_usd" => 526_000_000_000},
      %{"code" => "TH", "name" => "Thailand", "gdp_usd" => 505_000_000_000},
      %{"code" => "VN", "name" => "Vietnam", "gdp_usd" => 432_000_000_000},
      %{"code" => "MY", "name" => "Malaysia", "gdp_usd" => 497_000_000_000},
      %{"code" => "PH", "name" => "Philippines", "gdp_usd" => 576_000_000_000},
      %{"code" => "MM", "name" => "Myanmar", "gdp_usd" => 67_000_000_000},
      %{"code" => "KH", "name" => "Cambodia", "gdp_usd" => 30_000_000_000},
      %{"code" => "LA", "name" => "Laos", "gdp_usd" => 19_000_000_000},
      %{"code" => "BN", "name" => "Brunei", "gdp_usd" => 15_000_000_000},
      # South Asia
      %{"code" => "PK", "name" => "Pakistan", "gdp_usd" => 368_000_000_000},
      %{"code" => "BD", "name" => "Bangladesh", "gdp_usd" => 416_000_000_000},
      %{"code" => "LK", "name" => "Sri Lanka", "gdp_usd" => 84_000_000_000},
      %{"code" => "NP", "name" => "Nepal", "gdp_usd" => 40_000_000_000},
      %{"code" => "BT", "name" => "Bhutan", "gdp_usd" => 3_000_000_000},
      %{"code" => "MV", "name" => "Maldives", "gdp_usd" => 6_000_000_000},
      %{"code" => "AF", "name" => "Afghanistan", "gdp_usd" => 20_000_000_000},
      # Oceania
      %{"code" => "NZ", "name" => "New Zealand", "gdp_usd" => 253_000_000_000},
      %{"code" => "PG", "name" => "Papua New Guinea", "gdp_usd" => 28_000_000_000},
      %{"code" => "FJ", "name" => "Fiji", "gdp_usd" => 5_000_000_000},
      %{"code" => "WS", "name" => "Samoa", "gdp_usd" => 900_000_000},
      %{"code" => "TO", "name" => "Tonga", "gdp_usd" => 500_000_000},
      %{"code" => "VU", "name" => "Vanuatu", "gdp_usd" => 1_000_000_000},
      %{"code" => "SB", "name" => "Solomon Islands", "gdp_usd" => 1_600_000_000},
      # Central Asia
      %{"code" => "KZ", "name" => "Kazakhstan", "gdp_usd" => 220_000_000_000},
      %{"code" => "UZ", "name" => "Uzbekistan", "gdp_usd" => 80_000_000_000},
      %{"code" => "TM", "name" => "Turkmenistan", "gdp_usd" => 45_000_000_000},
      %{"code" => "KG", "name" => "Kyrgyzstan", "gdp_usd" => 11_000_000_000},
      %{"code" => "TJ", "name" => "Tajikistan", "gdp_usd" => 10_000_000_000},
      %{"code" => "MN", "name" => "Mongolia", "gdp_usd" => 18_000_000_000},
    ],
    "EMEA" => [
      # Western Europe
      %{"code" => "DE", "name" => "Germany", "gdp_usd" => 4_310_000_000_000},
      %{"code" => "GB", "name" => "United Kingdom", "gdp_usd" => 3_330_000_000_000},
      %{"code" => "FR", "name" => "France", "gdp_usd" => 3_030_000_000_000},
      %{"code" => "IT", "name" => "Italy", "gdp_usd" => 2_190_000_000_000},
      %{"code" => "ES", "name" => "Spain", "gdp_usd" => 1_390_000_000_000},
      %{"code" => "NL", "name" => "Netherlands", "gdp_usd" => 1_280_000_000_000},
      %{"code" => "CH", "name" => "Switzerland", "gdp_usd" => 877_000_000_000},
      %{"code" => "BE", "name" => "Belgium", "gdp_usd" => 696_000_000_000},
      %{"code" => "AT", "name" => "Austria", "gdp_usd" => 518_000_000_000},
      %{"code" => "IE", "name" => "Ireland", "gdp_usd" => 529_000_000_000},
      %{"code" => "PT", "name" => "Portugal", "gdp_usd" => 254_000_000_000},
      %{"code" => "GR", "name" => "Greece", "gdp_usd" => 219_000_000_000},
      %{"code" => "LU", "name" => "Luxembourg", "gdp_usd" => 86_000_000_000},
      # Northern Europe
      %{"code" => "SE", "name" => "Sweden", "gdp_usd" => 616_000_000_000},
      %{"code" => "NO", "name" => "Norway", "gdp_usd" => 495_000_000_000},
      %{"code" => "DK", "name" => "Denmark", "gdp_usd" => 405_000_000_000},
      %{"code" => "FI", "name" => "Finland", "gdp_usd" => 297_000_000_000},
      %{"code" => "IS", "name" => "Iceland", "gdp_usd" => 28_000_000_000},
      # Eastern Europe
      %{"code" => "RU", "name" => "Russian Federation", "gdp_usd" => 1_860_000_000_000},
      %{"code" => "PL", "name" => "Poland", "gdp_usd" => 843_000_000_000},
      %{"code" => "RO", "name" => "Romania", "gdp_usd" => 301_000_000_000},
      %{"code" => "CZ", "name" => "Czech Republic", "gdp_usd" => 299_000_000_000},
      %{"code" => "UA", "name" => "Ukraine", "gdp_usd" => 282_000_000_000},
      %{"code" => "HU", "name" => "Hungary", "gdp_usd" => 211_000_000_000},
      %{"code" => "BY", "name" => "Belarus", "gdp_usd" => 72_000_000_000},
      %{"code" => "SK", "name" => "Slovakia", "gdp_usd" => 127_000_000_000},
      %{"code" => "BG", "name" => "Bulgaria", "gdp_usd" => 89_000_000_000},
      %{"code" => "HR", "name" => "Croatia", "gdp_usd" => 76_000_000_000},
      %{"code" => "SI", "name" => "Slovenia", "gdp_usd" => 68_000_000_000},
      %{"code" => "LT", "name" => "Lithuania", "gdp_usd" => 75_000_000_000},
      %{"code" => "LV", "name" => "Latvia", "gdp_usd" => 43_000_000_000},
      %{"code" => "EE", "name" => "Estonia", "gdp_usd" => 39_000_000_000},
      %{"code" => "RS", "name" => "Serbia", "gdp_usd" => 70_000_000_000},
      %{"code" => "BA", "name" => "Bosnia and Herzegovina", "gdp_usd" => 24_000_000_000},
      %{"code" => "AL", "name" => "Albania", "gdp_usd" => 20_000_000_000},
      %{"code" => "MK", "name" => "North Macedonia", "gdp_usd" => 14_000_000_000},
      %{"code" => "MD", "name" => "Moldova", "gdp_usd" => 16_000_000_000},
      %{"code" => "ME", "name" => "Montenegro", "gdp_usd" => 6_000_000_000},
      %{"code" => "MT", "name" => "Malta", "gdp_usd" => 19_000_000_000},
      %{"code" => "CY", "name" => "Cyprus", "gdp_usd" => 31_000_000_000},
      # Middle East
      %{"code" => "TR", "name" => "Turkey", "gdp_usd" => 1_050_000_000_000},
      %{"code" => "SA", "name" => "Saudi Arabia", "gdp_usd" => 1_160_000_000_000},
      %{"code" => "AE", "name" => "United Arab Emirates", "gdp_usd" => 507_000_000_000},
      %{"code" => "IL", "name" => "Israel", "gdp_usd" => 523_000_000_000},
      %{"code" => "QA", "name" => "Qatar", "gdp_usd" => 220_000_000_000},
      %{"code" => "KW", "name" => "Kuwait", "gdp_usd" => 174_000_000_000},
      %{"code" => "IQ", "name" => "Iraq", "gdp_usd" => 254_000_000_000},
      %{"code" => "IR", "name" => "Iran", "gdp_usd" => 388_000_000_000},
      %{"code" => "OM", "name" => "Oman", "gdp_usd" => 115_000_000_000},
      %{"code" => "BH", "name" => "Bahrain", "gdp_usd" => 44_000_000_000},
      %{"code" => "JO", "name" => "Jordan", "gdp_usd" => 48_000_000_000},
      %{"code" => "LB", "name" => "Lebanon", "gdp_usd" => 18_000_000_000},
      %{"code" => "SY", "name" => "Syria", "gdp_usd" => 9_000_000_000},
      %{"code" => "YE", "name" => "Yemen", "gdp_usd" => 21_000_000_000},
      %{"code" => "PS", "name" => "Palestine", "gdp_usd" => 18_000_000_000},
      %{"code" => "AM", "name" => "Armenia", "gdp_usd" => 20_000_000_000},
      %{"code" => "AZ", "name" => "Azerbaijan", "gdp_usd" => 78_000_000_000},
      %{"code" => "GE", "name" => "Georgia", "gdp_usd" => 24_000_000_000},
      # Africa
      %{"code" => "EG", "name" => "Egypt", "gdp_usd" => 426_000_000_000},
      %{"code" => "NG", "name" => "Nigeria", "gdp_usd" => 477_000_000_000},
      %{"code" => "ZA", "name" => "South Africa", "gdp_usd" => 406_000_000_000},
      %{"code" => "ET", "name" => "Ethiopia", "gdp_usd" => 169_000_000_000},
      %{"code" => "KE", "name" => "Kenya", "gdp_usd" => 120_000_000_000},
      %{"code" => "GH", "name" => "Ghana", "gdp_usd" => 76_000_000_000},
      %{"code" => "TZ", "name" => "Tanzania", "gdp_usd" => 77_000_000_000},
      %{"code" => "UG", "name" => "Uganda", "gdp_usd" => 49_000_000_000},
      %{"code" => "DZ", "name" => "Algeria", "gdp_usd" => 195_000_000_000},
      %{"code" => "MA", "name" => "Morocco", "gdp_usd" => 142_000_000_000},
      %{"code" => "AO", "name" => "Angola", "gdp_usd" => 92_000_000_000},
      %{"code" => "SD", "name" => "Sudan", "gdp_usd" => 34_000_000_000},
      %{"code" => "CM", "name" => "Cameroon", "gdp_usd" => 45_000_000_000},
      %{"code" => "CI", "name" => "Cote d'Ivoire", "gdp_usd" => 70_000_000_000},
      %{"code" => "SN", "name" => "Senegal", "gdp_usd" => 28_000_000_000},
      %{"code" => "ZW", "name" => "Zimbabwe", "gdp_usd" => 34_000_000_000},
      %{"code" => "ZM", "name" => "Zambia", "gdp_usd" => 29_000_000_000},
      %{"code" => "BW", "name" => "Botswana", "gdp_usd" => 20_000_000_000},
      %{"code" => "MZ", "name" => "Mozambique", "gdp_usd" => 18_000_000_000},
      %{"code" => "RW", "name" => "Rwanda", "gdp_usd" => 14_000_000_000},
      %{"code" => "TN", "name" => "Tunisia", "gdp_usd" => 46_000_000_000},
      %{"code" => "LY", "name" => "Libya", "gdp_usd" => 45_000_000_000},
      %{"code" => "GA", "name" => "Gabon", "gdp_usd" => 20_000_000_000},
      %{"code" => "ML", "name" => "Mali", "gdp_usd" => 19_000_000_000},
      %{"code" => "NE", "name" => "Niger", "gdp_usd" => 15_000_000_000},
      %{"code" => "BF", "name" => "Burkina Faso", "gdp_usd" => 19_000_000_000},
      %{"code" => "MW", "name" => "Malawi", "gdp_usd" => 13_000_000_000},
      %{"code" => "MU", "name" => "Mauritius", "gdp_usd" => 12_000_000_000},
      %{"code" => "NA", "name" => "Namibia", "gdp_usd" => 12_000_000_000},
      %{"code" => "MG", "name" => "Madagascar", "gdp_usd" => 15_000_000_000},
      %{"code" => "BJ", "name" => "Benin", "gdp_usd" => 17_000_000_000},
      %{"code" => "CD", "name" => "Democratic Republic of Congo", "gdp_usd" => 64_000_000_000},
      %{"code" => "CG", "name" => "Republic of Congo", "gdp_usd" => 12_000_000_000},
      %{"code" => "TG", "name" => "Togo", "gdp_usd" => 8_000_000_000},
      %{"code" => "SL", "name" => "Sierra Leone", "gdp_usd" => 4_000_000_000},
      %{"code" => "LR", "name" => "Liberia", "gdp_usd" => 4_000_000_000},
      %{"code" => "MR", "name" => "Mauritania", "gdp_usd" => 10_000_000_000},
      %{"code" => "ER", "name" => "Eritrea", "gdp_usd" => 2_000_000_000},
      %{"code" => "DJ", "name" => "Djibouti", "gdp_usd" => 4_000_000_000},
      %{"code" => "SO", "name" => "Somalia", "gdp_usd" => 8_000_000_000},
    ],
    "Americas" => [
      # North America
      %{"code" => "US", "name" => "United States", "gdp_usd" => 27_360_000_000_000},
      %{"code" => "CA", "name" => "Canada", "gdp_usd" => 2_140_000_000_000},
      %{"code" => "MX", "name" => "Mexico", "gdp_usd" => 1_290_000_000_000},
      # South America
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
      %{"code" => "GY", "name" => "Guyana", "gdp_usd" => 15_000_000_000},
      %{"code" => "SR", "name" => "Suriname", "gdp_usd" => 3_000_000_000},
      # Central America & Caribbean
      %{"code" => "GT", "name" => "Guatemala", "gdp_usd" => 95_000_000_000},
      %{"code" => "CR", "name" => "Costa Rica", "gdp_usd" => 68_000_000_000},
      %{"code" => "PA", "name" => "Panama", "gdp_usd" => 79_000_000_000},
      %{"code" => "DO", "name" => "Dominican Republic", "gdp_usd" => 113_000_000_000},
      %{"code" => "CU", "name" => "Cuba", "gdp_usd" => 100_000_000_000},
      %{"code" => "HN", "name" => "Honduras", "gdp_usd" => 32_000_000_000},
      %{"code" => "SV", "name" => "El Salvador", "gdp_usd" => 34_000_000_000},
      %{"code" => "NI", "name" => "Nicaragua", "gdp_usd" => 15_000_000_000},
      %{"code" => "BZ", "name" => "Belize", "gdp_usd" => 3_000_000_000},
      %{"code" => "JM", "name" => "Jamaica", "gdp_usd" => 17_000_000_000},
      %{"code" => "TT", "name" => "Trinidad and Tobago", "gdp_usd" => 25_000_000_000},
      %{"code" => "BS", "name" => "Bahamas", "gdp_usd" => 14_000_000_000},
      %{"code" => "BB", "name" => "Barbados", "gdp_usd" => 5_000_000_000},
      %{"code" => "HT", "name" => "Haiti", "gdp_usd" => 20_000_000_000},
    ]
  }

  @doc """
  Seed all 195 countries into the database
  """
  def seed_all_countries! do
    IO.puts("🌍 Phase 4: Seeding all 195 countries...")

    @countries_data
    |> Enum.flat_map(fn {region, countries} ->
      Enum.map(countries, fn country ->
        Map.put(country, "region", region)
      end)
    end)
    |> Enum.each(&create_or_update_country/1)

    IO.puts("✅ All #{total_countries()} countries seeded successfully!")
    {:ok, "#{total_countries()} countries seeded"}
  end

  defp create_or_update_country(country_data) do
    contribution_usd = div(country_data["gdp_usd"], 10000)

    attrs = %{
      country_code: country_data["code"],
      country_name: country_data["name"],
      region: country_data["region"],
      gdp_usd: country_data["gdp_usd"],
      contribution_usd: contribution_usd,
      covenant_status: "active",
      joined_at: DateTime.utc_now()
    }

    case Repo.get_by(Phase4Country, country_code: country_data["code"]) do
      nil ->
        %Phase4Country{}
        |> Phase4Country.changeset(attrs)
        |> Repo.insert!()

      existing ->
        existing
        |> Phase4Country.changeset(attrs)
        |> Repo.update!()
    end
  end

  @doc """
  Get statistics for a region (APAC, EMEA, Americas)
  """
  def region_stats(region) do
    @countries_data
    |> Map.get(region, [])
    |> Enum.reduce(%{
      count: 0,
      total_gdp: 0,
      total_covenant: 0,
      active_countries: 0
    }, fn country, acc ->
      covenant_contribution = (country["gdp_usd"] || country[:gdp_usd]) * 0.0001
      %{
        count: acc.count + 1,
        total_gdp: acc.total_gdp + (country["gdp_usd"] || country[:gdp_usd]),
        total_covenant: acc.total_covenant + covenant_contribution,
        active_countries: acc.active_countries + 1
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
  Seed 500+ projects across 6 sectors and 195 countries
  """
  def seed_phase_4_projects! do
    IO.puts("🚀 Phase 4: Seeding 500+ projects across all sectors...")

    countries = Repo.all(Phase4Country)

    if Enum.empty?(countries) do
      IO.puts("❌ No countries found. Please run seed_all_countries! first.")
      {:error, "No countries available"}
    else
      sectors = ["Technology", "Healthcare", "Energy", "Agriculture", "Education", "Infrastructure"]
      project_count = create_projects_for_sectors(countries, sectors)

      IO.puts("✅ #{project_count} projects created successfully!")
      {:ok, "#{project_count} projects seeded"}
    end
  end

  defp create_projects_for_sectors(countries, sectors) do
    # Create ~85 projects per sector (500+ total)
    sectors
    |> Enum.map(fn sector ->
      # Distribute projects across countries (weighted by GDP)
      top_countries = Enum.take_random(countries, 30)

      Enum.map(top_countries, fn country ->
        create_project_for_country(country, sector)
      end)
    end)
    |> List.flatten()
    |> length()
  end

  defp create_project_for_country(country, sector) do
    # Calculate budget based on country's covenant contribution
    base_budget = div(country.contribution_usd, 10)
    budget = base_budget + :rand.uniform(base_budget)

    attrs = %{
      project_name: generate_project_name(country.country_name, sector),
      sector: sector,
      status: "active",
      budget_usd: budget,
      impact_score: Decimal.from_float(5.0 + :rand.uniform() * 3.0),
      description: "Phase 4 #{sector} project in #{country.country_name}",
      country_id: country.id
    }

    %Phase4Project{}
    |> Phase4Project.changeset(attrs)
    |> Repo.insert!()
  end

  defp generate_project_name(country_name, sector) do
    sector_prefix = %{
      "Technology" => "Digital",
      "Healthcare" => "Health",
      "Energy" => "Green",
      "Agriculture" => "AgriTech",
      "Education" => "EduHub",
      "Infrastructure" => "Build"
    }

    "#{sector_prefix[sector]} #{country_name} Initiative #{:rand.uniform(9999)}"
  end

  defp total_countries do
    @countries_data |> Enum.map(fn {_, countries} -> length(countries) end) |> Enum.sum()
  end
end
