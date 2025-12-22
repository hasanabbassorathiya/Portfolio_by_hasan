# Quick Fix: Analytics RLS Error

## The Error
```
Analytics error: PostgrestException(message: new row violates row-level security policy for table "analytics_summary"
```

## Quick Fix (2 minutes)

### Option 1: Using Supabase Dashboard (Easiest)

1. **Go to Supabase Dashboard:**
   - Open https://app.supabase.com
   - Select your project

2. **Open SQL Editor:**
   - Click **SQL Editor** in the left sidebar
   - Click **New query**

3. **Copy and Paste this SQL:**
   ```sql
   -- Fix Analytics Summary RLS Policy
   -- Make the trigger function bypass RLS when inserting
   CREATE OR REPLACE FUNCTION update_analytics_summary()
   RETURNS TRIGGER 
   SECURITY DEFINER -- This allows the function to bypass RLS
   AS $$
   BEGIN
     INSERT INTO analytics_summary (date, page_path, view_count)
     VALUES (CURRENT_DATE, NEW.page_path, 1)
     ON CONFLICT (date, page_path)
     DO UPDATE SET view_count = analytics_summary.view_count + 1;
     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Also add an INSERT policy as backup
   CREATE POLICY IF NOT EXISTS "Allow trigger to insert analytics summary"
     ON analytics_summary FOR INSERT
     WITH CHECK (true);
   ```

4. **Run the Query:**
   - Click **Run** (or press Cmd/Ctrl + Enter)
   - Wait for "Success" message

5. **Done!** The errors should stop immediately.

### Option 2: Using Supabase CLI

If you have Supabase CLI installed:

```bash
cd /Users/macbookm1pro/StudioProjects/portfolio
supabase db push
```

This will apply all pending migrations including the fix.

## Verify It Worked

1. **Restart your Flutter app** (hot reload is fine)
2. **Navigate to any page**
3. **Check console** - you should NOT see analytics errors anymore
4. **Check Supabase:**
   - Go to **Table Editor** → `analytics_summary`
   - You should see data being inserted

## What This Does

- **SECURITY DEFINER**: Makes the trigger function run with elevated privileges, allowing it to bypass RLS
- **INSERT Policy**: Adds a backup policy that allows inserts (though SECURITY DEFINER should handle it)

## Why This Happened

The `update_analytics_summary()` trigger function tries to INSERT into `analytics_summary` when a page view is recorded. However, RLS was blocking it because:
1. The function runs as the app user (not admin)
2. There was no INSERT policy for `analytics_summary`
3. The function needs to bypass RLS to work

## Still Seeing Errors?

If you still see errors after running the migration:

1. **Check the function exists:**
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'update_analytics_summary';
   ```
   Should return `update_analytics_summary`

2. **Check the function has SECURITY DEFINER:**
   ```sql
   SELECT prosecdef FROM pg_proc WHERE proname = 'update_analytics_summary';
   ```
   Should return `true`

3. **Verify the trigger exists:**
   ```sql
   SELECT tgname FROM pg_trigger WHERE tgname = 'trigger_update_analytics_summary';
   ```
   Should return `trigger_update_analytics_summary`

If any of these fail, the migration didn't run correctly. Try running it again.

