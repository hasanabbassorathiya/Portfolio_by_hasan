# Final Blog RLS Fix - With Role Specification

## The Issue

Even after creating policies, INSERT is still failing. The problem is that we need to specify `TO authenticated` in the policy.

## The Solution

Run this SQL in **Supabase Dashboard → SQL Editor**:

```sql
-- Check current policies
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Admins can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can update blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can delete blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Create policies with TO authenticated role specified
CREATE POLICY "Authenticated users can insert blogs"
  ON blogs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update blogs"
  ON blogs FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete blogs"
  ON blogs FOR DELETE
  TO authenticated
  USING (auth.uid() IS NOT NULL);

-- Verify policies
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'blogs' 
ORDER BY policyname;
```

## Key Change

Added `TO authenticated` to each policy. This explicitly tells Supabase that these policies apply to authenticated users.

## After Running

1. Check the first SELECT query - it shows current policies
2. Run the DROP and CREATE statements
3. Check the last SELECT query - it should show 3 new policies
4. Test: `./test_blog_with_auth.sh`

## Expected Result

After running this SQL:
- ✅ Policies will be created with `TO authenticated` role
- ✅ INSERT should work
- ✅ Blog creation with HTML content will succeed

The file `check_and_fix_blog_policies.sql` contains the complete SQL.

