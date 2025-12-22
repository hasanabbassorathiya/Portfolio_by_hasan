#!/bin/bash

# Test Blog Creation via Supabase API with Authentication
# This requires a JWT token from an authenticated user

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing Blog Creation via Supabase API (Authenticated)...${NC}\n"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check if variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found Supabase credentials${NC}"
echo ""

# Check if JWT token is provided
if [ -z "$JWT_TOKEN" ]; then
    echo -e "${YELLOW}⚠ JWT_TOKEN not found in environment${NC}"
    echo ""
    echo "To get a JWT token:"
    echo "1. Login to your Flutter app at /admin/login"
    echo "2. Open browser console (F12)"
    echo "3. Run: localStorage.getItem('supabase.auth.token')"
    echo "4. Or check: SupabaseService.auth?.currentSession?.accessToken"
    echo ""
    echo "Then run:"
    echo "  export JWT_TOKEN='your-token-here'"
    echo "  ./test_blog_api_authenticated.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Found JWT token${NC}"
echo ""

# Test blog data with HTML content
BLOG_DATA=$(cat <<EOF
{
  "title": "Test Blog Post via API (Authenticated)",
  "slug": "test-blog-authenticated-$(date +%s)",
  "content": "<p>This is a <strong>test blog post</strong> created via authenticated API.</p><p>It includes <em>HTML content</em> with an image:</p><img src=\"https://imgur.com/R28hqdz\" alt=\"Test Image\" />",
  "excerpt": "Testing blog creation with HTML content and authentication",
  "author": "Hasan Abbas Sorathiya",
  "read_time": "5 min",
  "category": "Testing",
  "image_url": "https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800",
  "tags": ["test", "api", "html", "authenticated"],
  "is_published": false
}
EOF
)

echo -e "${YELLOW}Attempting to create blog post with authentication...${NC}"
echo ""

# Make API call with JWT token
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${SUPABASE_URL}/rest/v1/blogs" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$BLOG_DATA")

# Split response and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ SUCCESS! Blog created successfully with authentication${NC}"
    echo ""
    echo "Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    echo -e "${GREEN}The API works correctly with authentication!${NC}"
    echo ""
    
    # Extract blog ID
    BLOG_ID=$(echo "$BODY" | jq -r '.[0].id' 2>/dev/null || echo "$BODY" | jq -r '.id' 2>/dev/null)
    
    if [ ! -z "$BLOG_ID" ] && [ "$BLOG_ID" != "null" ]; then
        echo -e "${BLUE}Blog ID: $BLOG_ID${NC}"
        echo ""
        echo "You can view it in Supabase Dashboard → Table Editor → blogs"
    fi
else
    echo -e "${RED}✗ FAILED! Blog creation failed${NC}"
    echo ""
    echo "Error Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    
    if echo "$BODY" | grep -q "JWT"; then
        echo -e "${YELLOW}⚠ JWT Token Error${NC}"
        echo "The JWT token might be expired or invalid."
        echo "Get a fresh token from your Flutter app after logging in."
    elif echo "$BODY" | grep -q "row-level security"; then
        echo -e "${YELLOW}⚠ RLS Policy Error${NC}"
        echo "The authenticated user might not have permission."
        echo "Check RLS policies in Supabase Dashboard."
    fi
fi

echo ""
echo -e "${YELLOW}Test Complete!${NC}"

