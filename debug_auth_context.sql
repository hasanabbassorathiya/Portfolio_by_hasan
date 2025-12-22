-- Debug Auth Context in RLS Policies
-- This helps us understand why auth.uid() might not be working

-- Create a test function to see what auth.uid() returns
CREATE OR REPLACE FUNCTION test_auth_uid()
RETURNS TEXT AS $$
BEGIN
  RETURN COALESCE(auth.uid()::TEXT, 'NULL');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test the function (this will show what auth.uid() returns)
-- Note: This needs to be run with a JWT token in the request
SELECT test_auth_uid() as auth_uid_result;

-- Alternative: Try a simpler policy that just checks if user exists
-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Try using a function that checks auth.jwt() instead
CREATE OR REPLACE FUNCTION is_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create policies using the function
CREATE POLICY "Authenticated users can insert blogs"
  ON blogs FOR INSERT
  WITH CHECK (is_authenticated());

CREATE POLICY "Authenticated users can update blogs"
  ON blogs FOR UPDATE
  USING (is_authenticated())
  WITH CHECK (is_authenticated());

CREATE POLICY "Authenticated users can delete blogs"
  ON blogs FOR DELETE
  USING (is_authenticated());

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

