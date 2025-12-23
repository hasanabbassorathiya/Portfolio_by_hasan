-- Add blog status and scheduling support
-- This migration adds status field and scheduled_publish_at for better blog management

-- Add status column (draft, private, published)
ALTER TABLE blogs 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft' 
CHECK (status IN ('draft', 'private', 'published'));

-- Add scheduled_publish_at for scheduling posts
ALTER TABLE blogs 
ADD COLUMN IF NOT EXISTS scheduled_publish_at TIMESTAMP WITH TIME ZONE;

-- Update existing published blogs to have status 'published'
UPDATE blogs 
SET status = 'published' 
WHERE is_published = true;

-- Update existing unpublished blogs to have status 'draft'
UPDATE blogs 
SET status = 'draft' 
WHERE is_published = false;

-- Create index for status
CREATE INDEX IF NOT EXISTS idx_blogs_status ON blogs(status);
CREATE INDEX IF NOT EXISTS idx_blogs_scheduled_publish_at ON blogs(scheduled_publish_at);

