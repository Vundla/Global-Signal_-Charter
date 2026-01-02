#!/bin/bash
# Phase 4 GraphQL API Test Suite

BASE_URL="http://localhost:4000/api/graphql"

echo "🧪 Testing Phase 4 GraphQL API..."
echo ""

# Test 1: Query all countries
echo "1️⃣ Query all countries (first 3):"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ countries { country_code country_name region gdp_usd contribution_usd } }"
  }' | jq '.data.countries[:3]'
echo ""

# Test 2: Global statistics
echo "2️⃣ Global covenant statistics:"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ globalStats { totalCountries globalGdp globalCovenantFund avgContribution } }"
  }' | jq '.data.globalStats'
echo ""

# Test 3: Filter by region
echo "3️⃣ Countries in APAC region:"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ countries(filter: {region: \"APAC\"}) { country_code country_name } }"
  }' | jq '.data.countries | length'
echo " countries found in APAC"
echo ""

# Test 4: Query projects
echo "4️⃣ Projects (first 3):"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ projects { project_name sector budget_usd impact_score } }"
  }' | jq '.data.projects[:3]'
echo ""

# Test 5: Projects by sector
echo "5️⃣ Technology sector projects:"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ projects(filter: {sector: \"Technology\"}) { project_name country { country_name } } }"
  }' | jq '.data.projects | length'
echo " technology projects"
echo ""

# Test 6: Regional stats
echo "6️⃣ Regional statistics:"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ regionalStats { region countryCount totalGdp totalCovenant } }"
  }' | jq '.data.regionalStats'
echo ""

# Test 7: Sectoral stats
echo "7️⃣ Sectoral statistics:"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ sectoralStats { sector projectCount totalBudget avgImpact } }"
  }' | jq '.data.sectoralStats'
echo ""

echo "✅ GraphQL API tests complete!"
