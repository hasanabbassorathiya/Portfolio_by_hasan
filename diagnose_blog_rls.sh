#!/bin/bash

# Diagnose Blog RLS Policy Issues
# This script helps identify why blog creation is still failing

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Diagnosing Blog RLS Policy Issues...${NC}\n"

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL or SUPABASE_ANON_KEY not found${NC}"
    exit 1
fi

EMAIL="hasanabbassorathiya12@gmail.com"
PASSWORD="Arrow@2013"

echo -e "${BLUE}Step 1: Authenticating...${NC}"
AUTH_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}")

JWT_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token' 2>/dev/null)
USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.user.id' 2>/dev/null)

if [ -z "$JWT_TOKEN" ] || [ "$JWT_TOKEN" = "null" ]; then
    echo -e "${RED}✗ Authentication failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Authenticated${NC}"
echo "  User ID: $USER_ID"
echo "  Token: ${JWT_TOKEN:0:50}..."
echo ""

echo -e "${BLUE}Step 2: Testing if user can query blogs (SELECT policy)...${NC}"
SELECT_TEST=$(curl -s -w "\n%{http_code}" -X GET \
  "${SUPABASE_URL}/rest/v1/blogs?select=id&limit=1" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${JWT_TOKEN}")

SELECT_CODE=$(echo "$SELECT_TEST" | tail -n1)
if [ "$SELECT_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ SELECT policy works${NC}"
else
    echo -e "${RED}✗ SELECT policy failed (code: $SELECT_CODE)${NC}"
fi
echo ""

echo -e "${BLUE}Step 3: Testing INSERT with minimal data...${NC}"
MINIMAL_BLOG=$(cat <<EOF
{
  "title": "Test $(date +%s)",
  "slug": "test-$(date +%s)",
  "content": "Test content",
  "author": "Test Author",
  "is_published": false
}
EOF
)

INSERT_TEST=$(curl -s -w "\n%{http_code}" -X POST \
  "${SUPABASE_URL}/rest/v1/blogs" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$MINIMAL_BLOG")

INSERT_CODE=$(echo "$INSERT_TEST" | tail -n1)
INSERT_BODY=$(echo "$INSERT_TEST" | sed '$d')

echo "HTTP Code: $INSERT_CODE"
if [ "$INSERT_CODE" -eq 201 ] || [ "$INSERT_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ INSERT works! Blog created successfully${NC}"
    echo "$INSERT_BODY" | jq '.' 2>/dev/null || echo "$INSERT_BODY"
    
    # Clean up - delete the test blog
    BLOG_ID=$(echo "$INSERT_BODY" | jq -r '.[0].id' 2>/dev/null || echo "$INSERT_BODY" | jq -r '.id' 2>/dev/null)
    if [ ! -z "$BLOG_ID" ] && [ "$BLOG_ID" != "null" ]; then
        echo ""
        echo -e "${YELLOW}Cleaning up test blog...${NC}"
        curl -s -X DELETE \
          "${SUPABASE_URL}/rest/v1/blogs?id=eq.${BLOG_ID}" \
          -H "apikey: ${SUPABASE_ANON_KEY}" \
          -H "Authorization: Bearer ${JWT_TOKEN}" > /dev/null
        echo -e "${GREEN}✓ Test blog deleted${NC}"
    fi
else
    echo -e "${RED}✗ INSERT failed${NC}"
    echo "Error:"
    echo "$INSERT_BODY" | jq '.' 2>/dev/null || echo "$INSERT_BODY"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "1. RLS policies not created correctly"
    echo "2. JWT token not being validated properly"
    echo "3. User doesn't have the right permissions"
    echo ""
    echo -e "${BLUE}Check in Supabase Dashboard:${NC}"
    echo "1. Go to Authentication → Policies"
    echo "2. Find 'blogs' table"
    echo "3. Verify these policies exist:"
    echo "   - 'Authenticated users can insert blogs'"
    echo "   - WITH CHECK: auth.uid() IS NOT NULL"
fi

echo ""
echo -e "${YELLOW}Diagnosis Complete!${NC}"

