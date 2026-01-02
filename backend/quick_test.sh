#!/bin/bash
echo "🧪 Quick GraphQL API Test"
echo "========================="
echo ""

# Test 1: Count countries
echo "1️⃣ Total countries:"
curl -s -X POST http://localhost:4000/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ countries { country_code } }"}' | jq '.data.countries | length'

# Test 2: Count projects  
echo ""
echo "2️⃣ Total projects:"
curl -s -X POST http://localhost:4000/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ projects { id } }"}' | jq '.data.projects | length'

# Test 3: Global stats
echo ""
echo "3️⃣ Global statistics:"
curl -s -X POST http://localhost:4000/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ globalStats { totalCountries globalGdp globalCovenantFund } }"}' | jq '.data.globalStats'

echo ""
echo "✅ API tests complete!"
