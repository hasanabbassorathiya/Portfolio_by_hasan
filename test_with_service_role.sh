#!/bin/bash

# Test Blog Creation with Service Role Key
# Service role key bypasses RLS - this helps us verify if the issue is RLS or something else

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Testing Blog Creation with Service Role Key (bypasses RLS)...${NC}\n"

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$SUPABASE_URL" ]; then
    echo -e "${RED}Error: SUPABASE_URL not found${NC}"
    exit 1
fi

# Check for service role key
if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${YELLOW}⚠ SUPABASE_SERVICE_ROLE_KEY not found in .env${NC}"
    echo ""
    echo "To get your service role key:"
    echo "1. Go to Supabase Dashboard → Settings → API"
    echo "2. Copy the 'service_role' key (NOT the anon key)"
    echo "3. Add to .env: SUPABASE_SERVICE_ROLE_KEY=your-service-role-key"
    echo ""
    echo "⚠ WARNING: Service role key has full access - keep it secret!"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Found service role key${NC}"
echo ""

# Test blog data
BLOG_DATA=$(cat <<EOF
{
  "title": "Test Blog via Service Role $(date +%H:%M:%S)",
  "slug": "test-service-role-$(date +%s)",
  "content": "<h1>Test</h1><p>This blog was created using <strong>service role key</strong> which bypasses RLS.</p><img src=\"https://imgur.com/R28hqdz\" alt=\"Test\" />",
  "excerpt": "Testing with service role",
  "author": "Hasan Abbas Sorathiya",
  "read_time": "5 min",
  "category": "Testing",
  "image_url": "https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800",
  "tags": ["test", "service-role"],
  "is_published": false
}
EOF
)

echo -e "${BLUE}Creating blog with service role key (bypasses RLS)...${NC}"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${SUPABASE_URL}/rest/v1/blogs" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$BLOG_DATA")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ SUCCESS! Blog created with service role key${NC}"
    echo ""
    echo "This proves:"
    echo "  ✅ Supabase API works"
    echo "  ✅ HTML content is supported"
    echo "  ✅ The issue is specifically with RLS policies"
    echo ""
    echo "Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    
    # Clean up
    BLOG_ID=$(echo "$BODY" | jq -r '.[0].id' 2>/dev/null || echo "$BODY" | jq -r '.id' 2>/dev/null)
    if [ ! -z "$BLOG_ID" ] && [ "$BLOG_ID" != "null" ]; then
        echo ""
        echo -e "${YELLOW}Cleaning up test blog...${NC}"
        curl -s -X DELETE \
          "${SUPABASE_URL}/rest/v1/blogs?id=eq.${BLOG_ID}" \
          -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
          -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" > /dev/null
        echo -e "${GREEN}✓ Test blog deleted${NC}"
    fi
else
    echo -e "${RED}✗ FAILED even with service role key${NC}"
    echo "This means the issue is NOT RLS - it's something else!"
    echo ""
    echo "Error:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
fi

echo ""
echo -e "${YELLOW}Test Complete!${NC}"

