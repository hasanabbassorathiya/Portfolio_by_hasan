#!/bin/bash

# Test Blog Creation with Authentication
# This script logs in to Supabase and then creates a blog post

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing Blog Creation with Authentication...${NC}\n"

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

# Credentials (from user)
EMAIL="hasanabbassorathiya12@gmail.com"
PASSWORD="Arrow@2013"

echo -e "${YELLOW}Step 1: Authenticating with Supabase...${NC}"

# Authenticate and get JWT token
AUTH_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${EMAIL}\",
    \"password\": \"${PASSWORD}\"
  }")

# Check if authentication was successful
if echo "$AUTH_RESPONSE" | grep -q "access_token"; then
    JWT_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token' 2>/dev/null)
    
    if [ -z "$JWT_TOKEN" ] || [ "$JWT_TOKEN" = "null" ]; then
        echo -e "${RED}✗ Failed to extract JWT token${NC}"
        echo "Response: $AUTH_RESPONSE"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Authentication successful!${NC}"
    echo "  Token: ${JWT_TOKEN:0:50}..."
    echo ""
else
    echo -e "${RED}✗ Authentication failed${NC}"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

echo -e "${YELLOW}Step 2: Creating blog post with HTML content...${NC}"

# Test blog data with HTML content
BLOG_DATA=$(cat <<EOF
{
  "title": "Test Blog Post via API $(date +%H:%M:%S)",
  "slug": "test-blog-api-$(date +%s)",
  "content": "<h1>Test Blog Post</h1><p>This is a <strong>test blog post</strong> created via authenticated API.</p><p>It includes <em>HTML content</em> with an image:</p><img src=\"https://imgur.com/R28hqdz\" alt=\"Test Image\" /><p>And some <a href=\"https://example.com\">links</a> too!</p>",
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
    echo -e "${GREEN}✓ SUCCESS! Blog created successfully!${NC}"
    echo ""
    echo "Response:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    
    # Extract blog ID and verify HTML content
    BLOG_ID=$(echo "$BODY" | jq -r '.[0].id' 2>/dev/null || echo "$BODY" | jq -r '.id' 2>/dev/null)
    CONTENT=$(echo "$BODY" | jq -r '.[0].content' 2>/dev/null || echo "$BODY" | jq -r '.content' 2>/dev/null)
    
    if [ ! -z "$BLOG_ID" ] && [ "$BLOG_ID" != "null" ]; then
        echo -e "${BLUE}Blog ID: $BLOG_ID${NC}"
        echo ""
        
        if echo "$CONTENT" | grep -q "<img"; then
            echo -e "${GREEN}✓ HTML content stored correctly (includes <img> tag)${NC}"
        fi
        if echo "$CONTENT" | grep -q "<h1"; then
            echo -e "${GREEN}✓ HTML content stored correctly (includes <h1> tag)${NC}"
        fi
        if echo "$CONTENT" | grep -q "<a href"; then
            echo -e "${GREEN}✓ HTML content stored correctly (includes <a> tag)${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}✅ CONCLUSION: Supabase API fully supports HTML content!${NC}"
        echo "The blog was created successfully with HTML tags preserved."
        echo ""
        echo "You can view it in:"
        echo "  - Supabase Dashboard → Table Editor → blogs"
        echo "  - Flutter app → Admin Dashboard → Blogs"
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
    elif echo "$BODY" | grep -q "row-level security"; then
        echo -e "${YELLOW}⚠ RLS Policy Error${NC}"
        echo "The authenticated user might not have permission."
        echo "Check RLS policies in Supabase Dashboard."
    fi
fi

echo ""
echo -e "${YELLOW}Test Complete!${NC}"

