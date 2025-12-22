-- COMPREHENSIVE BLOG RLS FIX
-- This script completely resets and recreates blog RLS policies
-- Run this in Supabase Dashboard → SQL Editor

-- Step 1: Check current policies
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;

-- Step 2: Disable RLS to drop all policies cleanly
ALTER TABLE blogs DISABLE ROW LEVEL SECURITY;

-- Step 3: Drop ALL existing policies (using DO block to handle any policy name)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'blogs') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON blogs';
    END LOOP;
END $$;

-- Step 4: Re-enable RLS
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;

-- Step 5: Create new policies (simple version - should work)
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

-- Step 6: Verify policies were created
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;

-- Expected output: 3 policies
-- 1. "Authenticated users can insert blogs" - INSERT
-- 2. "Authenticated users can update blogs" - UPDATE  
-- 3. "Authenticated users can delete blogs" - DELETE

