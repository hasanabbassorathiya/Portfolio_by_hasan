# Apply Blog RLS Fix - Step by Step

## Current Status
❌ Blog creation is failing with RLS policy error  
✅ Authentication is working  
✅ HTML content format is correct  

## The Problem
The RLS policy uses `auth.role() = 'authenticated'` which doesn't work in Supabase.  
We need to change it to `auth.uid() IS NOT NULL`.

## Solution: Run This SQL

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Select your project: `bxdoymhgeoelidgqialg`

### Step 2: Open SQL Editor
1. Click **SQL Editor** in the left sidebar
2. Click **New query** button

### Step 3: Copy and Paste This SQL

```sql
-- Fix Blog RLS Policies
-- Drop old policies
DROP POLICY IF EXISTS "Admins can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can update blogs" ON blogs;
DROP POLICY IF EXISTS "Admins can delete blogs" ON blogs;

-- Create new policies that work correctly
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

### Step 4: Run the Query
1. Click **Run** button (or press Cmd/Ctrl + Enter)
2. Wait for "Success" message

### Step 5: Test
Run the test script:
```bash
./test_blog_with_auth.sh
```

You should see:
```
✓ SUCCESS! Blog created successfully!
```

## What This Does

- **Removes** old policies that don't work (`auth.role() = 'authenticated'`)
- **Creates** new policies that work (`auth.uid() IS NOT NULL`)
- **Allows** any authenticated user to create/update/delete blogs

## Verify It Worked

After running the SQL:
1. Go to **Authentication → Policies**
2. Find **blogs** table
3. You should see:
   - ✅ "Authenticated users can insert blogs"
   - ✅ "Authenticated users can update blogs"
   - ✅ "Authenticated users can delete blogs"
4. The old "Admins can..." policies should be gone

## After Fix

Once applied:
- ✅ Blog creation will work via API
- ✅ Blog creation will work in Flutter app
- ✅ HTML content will be preserved
- ✅ All authenticated users can manage blogs

---

**The migration file is ready at:** `supabase/migrations/006_fix_blog_rls.sql`

