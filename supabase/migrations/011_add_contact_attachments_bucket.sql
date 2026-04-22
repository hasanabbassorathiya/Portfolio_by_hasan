-- Add contact_attachments bucket policies
-- This migration creates RLS policies for the contact_attachments storage bucket

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Public can upload contact attachments" ON storage.objects;
DROP POLICY IF EXISTS "Public can read contact attachments" ON storage.objects;

-- Allow public to upload (INSERT) to contact_attachments bucket
-- This allows anyone to submit contact form attachments
CREATE POLICY "Public can upload contact attachments"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'contact_attachments');

-- Allow public to read (SELECT) from contact_attachments bucket
-- This allows viewing uploaded attachments
CREATE POLICY "Public can read contact attachments"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'contact_attachments');

