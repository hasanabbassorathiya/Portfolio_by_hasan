#!/bin/bash

# Test Blog Creation via Supabase API
# This script tests if blog creation works directly through the API

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing Blog Creation via Supabase API...${NC}\n"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create a .env file with:"
    echo "  SUPABASE_URL=your_supabase_url"
    echo "  SUPABASE_ANON_KEY=your_anon_key"
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
echo "  URL: ${SUPABASE_URL}"
echo "  Key: ${SUPABASE_ANON_KEY:0:20}..."
echo ""

# Test blog data with HTML content
BLOG_DATA=$(cat <<EOF
{
  "title": "Test Blog Post via API",
  "slug": "test-blog-post-via-api-$(date +%s)",
  "content": "<p>This is a <strong>test blog post</strong> created via API.</p><p>It includes <em>HTML content</em> with an image:</p><img src=\"https://imgur.com/R28hqdz\" alt=\"Test Image\" />",
  "excerpt": "Testing blog creation with HTML content",
  "author": "Hasan Abbas Sorathiya",
  "read_time": "5 min",
  "category": "Testing",
  "image_url": "https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800",
  "tags": ["test", "api", "html"],
  "is_published": false
}
EOF
)

echo -e "${YELLOW}Attempting to create blog post...${NC}"
echo ""

# Make API call
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${SUPABASE_URL}/rest/v1/blogs" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$BLOG_DATA")

# Split response and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ SUCCESS! Blog created successfully${NC}"
    echo ""
    echo "Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    echo -e "${GREEN}The API is working correctly!${NC}"
    echo "If Flutter app still has issues, it's likely a client-side problem."
else
    echo -e "${RED}✗ FAILED! Blog creation failed${NC}"
    echo ""
    echo "Error Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    
    if echo "$BODY" | grep -q "row-level security"; then
        echo -e "${YELLOW}⚠ RLS Policy Error detected${NC}"
        echo "This means the Supabase RLS policies are blocking the insert."
        echo "Check your RLS policies for the 'blogs' table."
    elif echo "$BODY" | grep -q "JWT"; then
        echo -e "${YELLOW}⚠ Authentication Error${NC}"
        echo "The anon key might not have permission, or you need an authenticated user."
    else
        echo -e "${YELLOW}⚠ Unknown Error${NC}"
        echo "Check the error message above for details."
    fi
fi

echo ""
echo -e "${YELLOW}Testing HTML content handling...${NC}"

# Test if HTML content is stored correctly
if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
    BLOG_ID=$(echo "$BODY" | jq -r '.[0].id' 2>/dev/null || echo "$BODY" | jq -r '.id' 2>/dev/null)
    
    if [ ! -z "$BLOG_ID" ] && [ "$BLOG_ID" != "null" ]; then
        echo "Fetching created blog to verify HTML content..."
        
        FETCH_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
          "${SUPABASE_URL}/rest/v1/blogs?id=eq.${BLOG_ID}&select=id,title,content" \
          -H "apikey: ${SUPABASE_ANON_KEY}" \
          -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")
        
        FETCH_CODE=$(echo "$FETCH_RESPONSE" | tail -n1)
        FETCH_BODY=$(echo "$FETCH_RESPONSE" | sed '$d')
        
        if [ "$FETCH_CODE" -eq 200 ]; then
            CONTENT=$(echo "$FETCH_BODY" | jq -r '.[0].content' 2>/dev/null || echo "$FETCH_BODY" | jq -r '.content' 2>/dev/null)
            
            if echo "$CONTENT" | grep -q "<img"; then
                echo -e "${GREEN}✓ HTML content stored correctly (includes <img> tag)${NC}"
            else
                echo -e "${YELLOW}⚠ HTML content might have been modified${NC}"
                echo "Content preview: ${CONTENT:0:100}..."
            fi
        fi
    fi
fi

echo ""
echo -e "${YELLOW}Test Complete!${NC}"

