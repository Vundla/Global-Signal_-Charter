# Phase 4 Country Data Summary

**Generated**: 2026-01-02T12:43:28.732Z
**Total Countries**: 177
**Total Global GDP**: $104087.59B
**Total Covenant Contribution**: $1040.88M

## Regional Distribution

{
  "ams": {
    "country_count": 36,
    "total_gdp_usd_billions": "25901.00",
    "total_contribution_usd_millions": "259.01",
    "top_economies": [
      {
        "code": "DEU",
        "name": "Germany",
        "gdp": 4310
      },
      {
        "code": "GBR",
        "name": "United Kingdom",
        "gdp": 3330
      },
      {
        "code": "FRA",
        "name": "France",
        "gdp": 3030
      }
    ]
  },
  "iad": {
    "country_count": 49,
    "total_gdp_usd_billions": "35636.75",
    "total_contribution_usd_millions": "356.37",
    "top_economies": [
      {
        "code": "USA",
        "name": "United States",
        "gdp": 27360
      },
      {
        "code": "CAN",
        "name": "Canada",
        "gdp": 2140
      },
      {
        "code": "BRA",
        "name": "Brazil",
        "gdp": 2117
      }
    ]
  },
  "syd": {
    "country_count": 27,
    "total_gdp_usd_billions": "8946.04",
    "total_contribution_usd_millions": "89.46",
    "top_economies": [
      {
        "code": "JPN",
        "name": "Japan",
        "gdp": 4230
      },
      {
        "code": "KOR",
        "name": "South Korea",
        "gdp": 1780
      },
      {
        "code": "AUS",
        "name": "Australia",
        "gdp": 1738
      }
    ]
  },
  "sin": {
    "country_count": 37,
    "total_gdp_usd_billions": "31212.00",
    "total_contribution_usd_millions": "312.12",
    "top_economies": [
      {
        "code": "CHN",
        "name": "China",
        "gdp": 17799
      },
      {
        "code": "IND",
        "name": "India",
        "gdp": 3736
      },
      {
        "code": "IDN",
        "name": "Indonesia",
        "gdp": 1320
      }
    ]
  },
  "sfo": {
    "country_count": 0,
    "total_gdp_usd_billions": "0.00",
    "total_contribution_usd_millions": "0.00",
    "top_economies": []
  },
  "jnb": {
    "country_count": 27,
    "total_gdp_usd_billions": "2384.80",
    "total_contribution_usd_millions": "23.85",
    "top_economies": [
      {
        "code": "NGA",
        "name": "Nigeria",
        "gdp": 477
      },
      {
        "code": "EGY",
        "name": "Egypt",
        "gdp": 476
      },
      {
        "code": "ZAF",
        "name": "South Africa",
        "gdp": 405
      }
    ]
  }
}

## Files Generated

1. `phase4_countries.sql` - SQL script for database population
2. `phase4_countries.json` - JSON data export for API seeding
3. `PHASE4_COUNTRIES.md` - This documentation

## Migration Instructions

```bash
# Run SQL script against PostgreSQL
psql -h localhost -U global-signal_-charter global_DB < phase4_countries.sql

# Or use Elixir migration
mix ecto.migrate

# Verify
mix ecto.query "SELECT COUNT(*) FROM countries"
# Expected: 195
```

## API Integration

Once imported, access via GraphQL:

```graphql
query GetCountries {
  countries(limit: 195) {
    code
    name
    gdp_usd_billions
    covenant_contribution_usd_millions
    region
  }
}
```

---

**Phase**: 4 (Global Expansion)  
**Status**: ✅ Complete
