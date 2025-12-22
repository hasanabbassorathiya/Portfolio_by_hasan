# Supabase Storage Setup Guide

## Issue: "Bucket not found" Error

If you're getting a "storage exception bucket not found" error, you need to create the storage bucket in Supabase.

## Steps to Create Storage Bucket

### 1. Go to Supabase Dashboard
1. Open your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar

### 2. Create Bucket
1. Click **"New bucket"** or **"Create bucket"**
2. Enter bucket name: `avatars` (or whatever bucket name you're using)
3. Set bucket to **Public** (if you want public access to images)
   - Or **Private** if you want signed URLs only
4. Click **"Create bucket"**

### 3. Configure Bucket Policies (if needed)

If the bucket is private, you'll need to set up policies:

1. Go to **Storage** → **Policies**
2. Click on your bucket name
3. Add policies for:
   - **INSERT**: Allow authenticated users to upload
   - **SELECT**: Allow public or authenticated users to read
   - **UPDATE**: Allow authenticated users to update
   - **DELETE**: Allow authenticated users to delete

Example policy for authenticated users:
```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Allow public to read
CREATE POLICY "Public can read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

## Common Bucket Names Used in This Project

Based on the code, these buckets are expected:
- `avatars` - For profile images
- `blogs` - For blog images (if used)
- `works` - For work/project images (if used)
- `testimonials` - For testimonial images (if used)

## Verify Bucket Exists

After creating the bucket, you can verify it exists by:
1. Going to **Storage** → **Buckets**
2. You should see your bucket listed
3. Try uploading a test file manually to confirm it works

## Debugging

With the new logging, check your browser console (F12) for:
- `StorageService.uploadImageWeb: Starting web upload...`
- `StorageService.uploadImageWeb: Bucket: avatars`
- `StorageService.uploadImageWeb: Checking bucket access...`
- If bucket doesn't exist, you'll see: `Bucket "avatars" not found or not accessible`

## Quick Fix

If you're in a hurry, create the bucket with these settings:
- **Name**: `avatars`
- **Public**: Yes (for easy access)
- **File size limit**: 5MB (or as needed)
- **Allowed MIME types**: `image/*` (or leave empty for all)

Then try uploading again!

## ⚠️ IMPORTANT: Storage RLS Policies

If you get an error like:
```
StorageException(message: new row violates row-level security policy, statusCode: 403)
```

This means you need to set up RLS policies for storage. Run this migration:

**File**: `supabase/migrations/008_setup_storage_policies.sql`

Or manually create policies in Supabase Dashboard:

1. Go to **Storage** → **Policies**
2. Click on **storage.objects** table
3. Add these policies:

### For Authenticated Users to Upload:
```sql
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');
```

### For Public to Read:
```sql
CREATE POLICY "Public can read avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

### For Authenticated Users to Update:
```sql
CREATE POLICY "Authenticated users can update avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
```

### For Authenticated Users to Delete:
```sql
CREATE POLICY "Authenticated users can delete avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');
```

**After creating these policies, try uploading again!**

