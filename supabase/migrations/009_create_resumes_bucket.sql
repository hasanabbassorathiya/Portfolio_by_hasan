-- Create resumes storage bucket and policies
-- This migration sets up storage for resume PDFs

-- Note: Buckets must be created manually in Supabase Dashboard
-- Go to Storage → Create Bucket → Name: "resumes" → Public: true (or configure RLS)

-- Storage policies for resumes bucket
-- Allow authenticated users to upload resumes
DROP POLICY IF EXISTS "Authenticated users can upload resumes" ON storage.objects;
CREATE POLICY "Authenticated users can upload resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'resumes');

-- Allow authenticated users to update their resumes
DROP POLICY IF EXISTS "Authenticated users can update resumes" ON storage.objects;
CREATE POLICY "Authenticated users can update resumes"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'resumes')
WITH CHECK (bucket_id = 'resumes');

-- Allow authenticated users to delete resumes
DROP POLICY IF EXISTS "Authenticated users can delete resumes" ON storage.objects;
CREATE POLICY "Authenticated users can delete resumes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'resumes');

-- Allow public to read resumes (or restrict as needed)
DROP POLICY IF EXISTS "Public can read resumes" ON storage.objects;
CREATE POLICY "Public can read resumes"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'resumes');

