# Blog HTML Posting Issues - Fixed

## Issues Fixed

### 1. Analytics RLS Policy Error ✅

**Error:**
```
Analytics error: PostgrestException(message: new row violates row-level security policy for table "analytics_summary"
```

**Cause:**
The `update_analytics_summary()` trigger function tried to INSERT into `analytics_summary`, but RLS blocked it because there was no INSERT policy.

**Fix:**
Created migration `005_fix_analytics_rls.sql` that:
- Makes the trigger function run with `SECURITY DEFINER` to bypass RLS
- Adds an INSERT policy as a backup

**To Apply:**
1. Go to Supabase Dashboard → SQL Editor
2. Run the migration: `supabase/migrations/005_fix_analytics_rls.sql`
3. Or run: `supabase db push`

### 2. Image URL Asset Error ✅

**Error:**
```
Error while trying to load an asset: Flutter Web engine failed to fetch
"assets/https%253A//imgur.com/R28hqdz". HTTP request succeeded, but the server responded with HTTP status 404.
```

**Cause:**
Image URLs in HTML content were being:
- Double-encoded (`https://` became `https%253A%2F%2F`)
- Treated as asset paths (prefixed with `assets/`)

**Fix:**
Added `_sanitizeHtmlContent()` method that:
- Removes `assets/` prefix from network URLs
- Decodes double-encoded URLs
- Handles both single and double quotes in HTML

**Location:**
`lib/views/blogs/blog_detail.dart` - `_sanitizeHtmlContent()` method

## Testing

After applying the fixes:

1. **Test Analytics:**
   - Navigate to any page
   - Check console - should NOT see analytics RLS errors
   - Check Supabase → Table Editor → `analytics_summary` - should have data

2. **Test Blog HTML Images:**
   - Create/edit a blog with HTML content
   - Add an image: `<img src="https://imgur.com/example.jpg" />`
   - Save and view the blog
   - Image should load correctly (not try to load as asset)

## Migration File

The analytics fix requires running the migration:
- File: `supabase/migrations/005_fix_analytics_rls.sql`
- This makes the trigger function bypass RLS when inserting analytics summaries

## Code Changes

1. **Analytics Fix:**
   - New migration file: `supabase/migrations/005_fix_analytics_rls.sql`
   - Updates trigger function to use `SECURITY DEFINER`

2. **Image URL Fix:**
   - Added `_sanitizeHtmlContent()` method in `blog_detail.dart`
   - Automatically fixes malformed image URLs before rendering HTML

Both fixes are now in place and should resolve the errors when posting blogs with HTML content.

