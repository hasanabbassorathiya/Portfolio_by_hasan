# Blog Creation Troubleshooting

## Current Status

You tried to create a blog with HTML content in the Flutter app, but it failed.

## What I've Done

1. ✅ **Improved error handling** - Now shows detailed error messages
2. ✅ **Added authentication check** - Verifies you're logged in before saving
3. ✅ **Added debug logging** - Check browser console (F12) for detailed logs

## Next Steps

### Step 1: Check the Error Message

When you try to create a blog now, you should see a more detailed error message. Common errors:

- **"Permission denied"** → RLS policy issue (most likely)
- **"You must be logged in"** → Session expired, log in again
- **"A blog with this slug already exists"** → Change the title/slug

### Step 2: Check Browser Console

Open browser console (F12 → Console) and look for:
```
Blog Save: User authenticated - your@email.com
Blog Save: User ID - uuid-here
Blog Save: Attempting to insert blog
Blog Save Error: [error details]
```

### Step 3: Fix RLS Policies (If Needed)

If you see "Permission denied" or "row-level security" error, run this SQL in Supabase:

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can insert blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON blogs;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON blogs;

-- Create function approach
CREATE OR REPLACE FUNCTION check_user_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create policies using function
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
```

### Step 4: Verify You're Logged In

Before creating a blog:
1. Go to `/admin/login`
2. Make sure you're logged in
3. Check browser console for: `Blog Save: User authenticated`

## Common Issues

### Issue 1: RLS Policy Error
**Symptom**: "Permission denied" or "row-level security"  
**Fix**: Run the SQL above

### Issue 2: Session Expired
**Symptom**: "You must be logged in"  
**Fix**: Log out and log back in

### Issue 3: Duplicate Slug
**Symptom**: "A blog with this slug already exists"  
**Fix**: Change the blog title or slug

### Issue 4: HTML Content Issues
**Symptom**: Blog saves but images don't display  
**Fix**: The HTML sanitization should handle this automatically

## Test Again

After applying fixes:
1. **Hot reload** the Flutter app (press `r` in terminal)
2. **Try creating a blog** with HTML content
3. **Check console** for detailed logs
4. **Check error message** - it should be more helpful now

## If Still Failing

Share:
1. The exact error message you see
2. The console logs (F12 → Console)
3. Whether you're logged in (check Admin Dashboard)

The improved error handling will help us identify the exact issue!

