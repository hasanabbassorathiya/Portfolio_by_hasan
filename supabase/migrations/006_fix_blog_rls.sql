-- Fix Blog RLS Policies
-- The current policy uses auth.role() which doesn't work correctly
-- This migration fixes it to use auth.uid() to check if user is authenticated

-- Drop ALL existing blog policies (both old and new) to avoid conflicts
DROP POLICY IF EXISTS "Admins can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can update blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can delete blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Create new policies that check for authenticated users
-- auth.uid() returns the user ID if authenticated, null otherwise
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

-- Note: If you want to restrict to specific admin users only,
-- you would need to create an admin_users table and check:
-- USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()))
-- For now, any authenticated user can manage blogs (which is fine for a portfolio CMS)

