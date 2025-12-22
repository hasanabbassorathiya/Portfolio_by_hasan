-- Try Using SECURITY DEFINER Function for RLS
-- This approach uses a function that runs with elevated privileges

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Create a function that checks if user is authenticated
-- SECURITY DEFINER allows it to access auth.uid() even in RLS context
CREATE OR REPLACE FUNCTION check_user_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
  -- This should work because the function runs with SECURITY DEFINER
  RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create policies using the function
CREATE POLICY "Authenticated users can insert blogs"
  ON blogs FOR INSERT
  WITH CHECK (check_user_authenticated());

CREATE POLICY "Authenticated users can update blogs"
  ON blogs FOR UPDATE
  USING (check_user_authenticated())
  WITH CHECK (check_user_authenticated());

CREATE POLICY "Authenticated users can delete blogs"
  ON blogs FOR DELETE
  USING (check_user_authenticated());

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

