# Quick Fix: Blog RLS Policy Error

## The Error
```
new row violates row-level security policy for table "blogs"
```

## Root Cause

The RLS policy uses `auth.role() = 'authenticated'` which doesn't work correctly in Supabase. We need to use `auth.uid() IS NOT NULL` instead.

## Quick Fix (2 minutes)

### Step 1: Run the Migration

Go to **Supabase Dashboard → SQL Editor** and run:

```sql
-- Fix Blog RLS Policies
DROP POLICY IF EXISTS "Admins can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can update blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can delete blogs" ON blogs;

-- Create new policies that check for authenticated users
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
```

### Step 2: Test Again

Run the test script:
```bash
./test_blog_with_auth.sh
```

It should now work! ✅

## What Changed

- **Before**: `auth.role() = 'authenticated'` (doesn't work)
- **After**: `auth.uid() IS NOT NULL` (works correctly)

The `auth.uid()` function returns the user's UUID if they're authenticated, or `NULL` if not. This is the correct way to check authentication in Supabase RLS policies.

## Verify It Worked

After running the migration:
1. ✅ Authentication should work (already working)
2. ✅ Blog creation should work (will work after migration)
3. ✅ HTML content should be preserved (already working)

The migration file is at: `supabase/migrations/006_fix_blog_rls.sql`

