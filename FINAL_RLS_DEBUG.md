# Final RLS Debug - Why auth.uid() Might Not Work

## Current Situation

✅ Policies are created correctly  
✅ JWT token is valid and contains user ID  
✅ Authentication works  
❌ INSERT still fails with RLS error  

## Possible Causes

### 1. Supabase REST API Not Extracting User from JWT

When using the REST API directly (curl), Supabase might not be properly setting the auth context for RLS policies. This is a known issue in some cases.

### 2. Try Using a Function Instead

Run this SQL to create a helper function:

```sql
-- Create a function that checks authentication
CREATE OR REPLACE FUNCTION is_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate policies using the function
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

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
```

### 3. Test with Service Role Key

The service role key bypasses RLS. If blog creation works with it, it confirms the issue is RLS-specific.

1. Get your service role key from Supabase Dashboard → Settings → API
2. Add to `.env`: `SUPABASE_SERVICE_ROLE_KEY=your-key`
3. Run: `./test_with_service_role.sh`

If this works, it confirms:
- ✅ API works
- ✅ HTML content works
- ❌ RLS is the issue

### 4. Alternative: Temporarily Disable RLS for Testing

```sql
-- TEMPORARY: Disable RLS to test if that's the issue
ALTER TABLE blogs DISABLE ROW LEVEL SECURITY;
```

Then test blog creation. If it works, RLS is definitely the issue.

**⚠️ Remember to re-enable RLS after testing:**
```sql
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;
```

## Next Steps

1. **Try the function approach** (SQL above)
2. **Test with service role key** to confirm it's RLS
3. **Check Supabase logs** for more details:
   - Dashboard → Logs → Postgres Logs
   - Look for RLS-related errors

## Most Likely Solution

The issue might be that Supabase REST API doesn't properly extract the user from the JWT for RLS when using curl. The Flutter app should work because it uses the Supabase Flutter SDK which handles this correctly.

**Try creating a blog from the Flutter app** - it might work even though curl doesn't!

