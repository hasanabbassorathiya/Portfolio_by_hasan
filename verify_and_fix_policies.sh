#!/bin/bash

# Verify and Fix Blog RLS Policies
# This script checks what policies exist and provides the exact SQL to fix them

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Verifying Blog RLS Policies...${NC}\n"

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL or SUPABASE_ANON_KEY not found${NC}"
    exit 1
fi

echo -e "${BLUE}To check your current policies:${NC}"
echo ""
echo "1. Go to Supabase Dashboard → Authentication → Policies"
echo "2. Find the 'blogs' table"
echo "3. Check what policies exist"
echo ""
echo -e "${YELLOW}OR run this SQL query in Supabase Dashboard → SQL Editor:${NC}"
echo ""
cat <<'EOF'
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;
EOF

echo ""
echo -e "${BLUE}Then run this SQL to fix ALL policies:${NC}"
echo ""

cat <<'EOF'
-- COMPREHENSIVE BLOG RLS FIX
-- This will work regardless of what policies currently exist

-- Step 1: Disable RLS temporarily to drop all policies
ALTER TABLE blogs DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL possible policy names
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'blogs') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON blogs';
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;

-- Step 4: Create new policies (try without TO authenticated first)
CREATE POLICY "Authenticated users can insert blogs"
  ON blogs FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update blogs"
  ON blogs FOR UPDATE
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete blogs"
  ON blogs FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- Step 5: Verify
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;
EOF

echo ""
echo -e "${GREEN}After running the SQL, test again with:${NC}"
echo "  ./test_blog_with_auth.sh"

