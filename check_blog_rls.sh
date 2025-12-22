#!/bin/bash

# Check current Blog RLS policies in Supabase
# This helps verify if the migration was applied

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Checking Blog RLS Policies...${NC}\n"

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL or SUPABASE_ANON_KEY not found${NC}"
    exit 1
fi

echo -e "${YELLOW}To check your RLS policies:${NC}"
echo ""
echo "1. Go to Supabase Dashboard:"
echo "   https://app.supabase.com"
echo ""
echo "2. Navigate to: Authentication → Policies"
echo ""
echo "3. Find the 'blogs' table policies"
echo ""
echo "4. You should see policies like:"
echo "   - 'Authenticated users can insert blogs'"
echo "   - 'Authenticated users can update blogs'"
echo "   - 'Authenticated users can delete blogs'"
echo ""
echo "5. If you see 'Admins can insert blogs' instead,"
echo "   the migration hasn't been applied yet."
echo ""
echo -e "${YELLOW}To apply the fix:${NC}"
echo ""
echo "1. Go to Supabase Dashboard → SQL Editor"
echo "2. Click 'New query'"
echo "3. Copy and paste the SQL from: supabase/migrations/006_fix_blog_rls.sql"
echo "4. Click 'Run'"
echo "5. Wait for 'Success' message"
echo ""
echo -e "${GREEN}After applying, run: ./test_blog_with_auth.sh${NC}"

