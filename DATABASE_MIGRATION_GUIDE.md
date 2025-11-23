# Database Migration Guide

## 🔴 Error: "Could not find the table 'public.page_views'"

This error means the analytics tables haven't been created yet. You need to run the migration.

## Quick Fix: Run Analytics Migration

### Option 1: Using Supabase Dashboard (Easiest)

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **SQL Editor**
4. Click **New query**
5. Copy the entire contents of `supabase/migrations/003_analytics_and_config.sql`
6. Paste it into the SQL Editor
7. Click **Run** (or press Cmd/Ctrl + Enter)
8. Wait for success message

### Option 2: Using Supabase CLI

If you have Supabase CLI installed:

```bash
# Navigate to project root
cd /Users/macbookm1pro/StudioProjects/portfolio

# Push all migrations
supabase db push

# Or push specific migration
supabase db push --file supabase/migrations/003_analytics_and_config.sql
```

### Option 3: Run SQL Directly

1. Open `supabase/migrations/003_analytics_and_config.sql`
2. Copy all the SQL
3. Go to Supabase Dashboard → SQL Editor
4. Paste and run

## What This Migration Creates

The migration creates these tables:
- `page_views` - Tracks page visits
- `custom_events` - Tracks custom user events
- `remote_config` - Stores remote configuration
- `analytics_summary` - Aggregated analytics data

## Verify Migration Success

After running the migration:

1. Go to Supabase Dashboard → **Table Editor**
2. You should see these new tables:
   - `page_views`
   - `custom_events`
   - `remote_config`
   - `analytics_summary`

3. Restart your Flutter app
4. The analytics errors should be gone

## If You Still See Errors

1. **Check table exists:**
   - Go to Supabase Dashboard → Table Editor
   - Look for `page_views` table
   - If it doesn't exist, the migration didn't run successfully

2. **Check RLS policies:**
   - Go to Supabase Dashboard → Authentication → Policies
   - Make sure policies exist for `page_views` and `custom_events`

3. **Check logs:**
   - Go to Supabase Dashboard → Logs → Postgres Logs
   - Look for any errors during migration

## All Migrations

Make sure you've run all migrations in order:

1. ✅ `001_initial_schema.sql` - Creates main tables (profiles, works, blogs, etc.)
2. ✅ `002_seed_data.sql` - Optional seed data
3. ✅ `003_analytics_and_config.sql` - Creates analytics tables

## Firebase Configuration (Optional)

The Firebase errors are expected if you haven't configured Firebase yet. The app will work without Firebase - it's optional.

To configure Firebase for web:
1. Add Firebase config to `web/index.html`
2. See Firebase documentation for web setup

For now, you can ignore Firebase errors - they won't break the app.

