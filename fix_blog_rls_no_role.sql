-- Fix Blog RLS - Remove TO authenticated (let auth.uid() handle it)
-- Run this in Supabase Dashboard → SQL Editor

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Create policies WITHOUT TO authenticated role
-- Just rely on auth.uid() check - this should work for any authenticated JWT
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

-- Verify
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;

