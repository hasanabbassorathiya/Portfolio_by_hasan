# Database Setup Guide

Complete guide for setting up the Portfolio CMS database in Supabase.

## Overview

The database uses PostgreSQL (via Supabase) with the following main tables:

- `profiles` - User profile information
- `works` - Portfolio projects
- `blogs` - Blog posts
- `experiences` - Work experience
- `services` - Services offered
- `testimonials` - Client testimonials
- `social_links` - Social media links
- `contact_messages` - Contact form submissions
- `page_views` - Analytics page views
- `custom_events` - Analytics custom events
- `analytics_summary` - Aggregated analytics
- `remote_config` - Remote configuration

## Quick Setup

### Using Supabase CLI (Recommended)

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Push all migrations
supabase db push
```

### Manual Setup

1. Go to Supabase Dashboard → **SQL Editor**
2. Run each migration file in order from `docs/sql/`:
   - `001_initial_schema.sql`
   - `002_seed_data.sql`
   - `003_analytics_and_config.sql`
   - `004_admin_policies.sql`
   - `005_fix_analytics_rls.sql`
   - `006_fix_blog_rls.sql`
   - `007_add_blog_status_and_scheduling.sql`
   - `008_setup_storage_policies.sql`

## Migration Files

All SQL migration files are located in `docs/sql/`:

### 001_initial_schema.sql
Creates all base tables:
- profiles
- works
- blogs
- experiences
- services
- testimonials
- social_links
- contact_messages

### 002_seed_data.sql
Optional seed data (can be skipped for fresh setup)

### 003_analytics_and_config.sql
Creates analytics tables and remote config:
- page_views
- custom_events
- analytics_summary
- remote_config
- Analytics trigger functions

### 004_admin_policies.sql
Sets up Row Level Security (RLS) policies for admin access

### 005_fix_analytics_rls.sql
Fixes analytics summary RLS to allow trigger function inserts

### 006_fix_blog_rls.sql
Fixes blog RLS policies for authenticated admin users

### 007_add_blog_status_and_scheduling.sql
Adds blog status (draft/published/private) and scheduling support

### 008_setup_storage_policies.sql
Sets up storage bucket policies for file uploads

## Row Level Security (RLS)

All tables have RLS enabled for security:

- **Public tables** (profiles, works, blogs, etc.): Read-only for public, full access for authenticated admins
- **Admin-only tables** (contact_messages, analytics): Only accessible by authenticated admins
- **Storage buckets**: Public read, authenticated write

## Verifying Setup

### Check Tables

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

### Check RLS Policies

```sql
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### Check Storage Buckets

1. Go to Supabase Dashboard → **Storage**
2. Verify these buckets exist:
   - avatars
   - works
   - blogs
   - services
   - testimonials

## Troubleshooting

### Migration Errors

If a migration fails:

1. Check the error message in Supabase SQL Editor
2. Common issues:
   - Table already exists: Skip that migration or drop the table first
   - Policy already exists: The migration should handle this with `DROP POLICY IF EXISTS`
   - Missing dependency: Run migrations in order

### RLS Policy Issues

If you get "row-level security policy violation":

1. Verify you're authenticated (check JWT token)
2. Check that policies exist: `SELECT * FROM pg_policies WHERE tablename = 'your_table';`
3. Re-run the relevant policy migration

### Storage Access Issues

If file uploads fail:

1. Verify buckets exist
2. Check bucket is public or policies allow access
3. Run `008_setup_storage_policies.sql` migration

## Backup & Restore

### Backup Database

```bash
# Using Supabase CLI
supabase db dump -f backup.sql

# Or via Supabase Dashboard
# Go to Settings → Database → Backups
```

### Restore Database

```bash
# Using Supabase CLI
supabase db reset

# Or manually via SQL Editor
# Paste your backup SQL and run
```

## Next Steps

- [Storage Setup](STORAGE.md)
- [Admin Setup](ADMIN.md)
- [API Documentation](../api/API.md)

