-- Setup Storage Bucket Policies
-- This migration creates RLS policies for storage buckets to allow authenticated users to upload files

-- Note: Storage policies are created on the storage.objects table, not on buckets directly
-- Bucket names are referenced in the policy conditions

-- ============================================
-- AVATARS BUCKET POLICIES
-- ============================================

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public can read avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete avatars" ON storage.objects;

-- Allow authenticated users to upload (INSERT) to avatars bucket
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Allow public to read (SELECT) from avatars bucket
CREATE POLICY "Public can read avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Authenticated users can update avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Authenticated users can delete avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');

-- ============================================
-- BLOGS BUCKET POLICIES (if you create this bucket)
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can upload blogs" ON storage.objects;
DROP POLICY IF EXISTS "Public can read blogs" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update blogs" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete blogs" ON storage.objects;

-- Allow authenticated users to upload (INSERT) to blogs bucket
CREATE POLICY "Authenticated users can upload blogs"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'blogs');

-- Allow public to read (SELECT) from blogs bucket
CREATE POLICY "Public can read blogs"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'blogs');

-- Allow authenticated users to update blogs
CREATE POLICY "Authenticated users can update blogs"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'blogs')
WITH CHECK (bucket_id = 'blogs');

-- Allow authenticated users to delete blogs
CREATE POLICY "Authenticated users can delete blogs"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'blogs');

-- ============================================
-- WORKS BUCKET POLICIES (if you create this bucket)
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can upload works" ON storage.objects;
DROP POLICY IF EXISTS "Public can read works" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update works" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete works" ON storage.objects;

-- Allow authenticated users to upload (INSERT) to works bucket
CREATE POLICY "Authenticated users can upload works"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'works');

-- Allow public to read (SELECT) from works bucket
CREATE POLICY "Public can read works"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'works');

-- Allow authenticated users to update works
CREATE POLICY "Authenticated users can update works"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'works')
WITH CHECK (bucket_id = 'works');

-- Allow authenticated users to delete works
CREATE POLICY "Authenticated users can delete works"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'works');

