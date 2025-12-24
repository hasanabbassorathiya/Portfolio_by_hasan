-- Add quote field to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS quote TEXT;

-- Add app store links to works table
ALTER TABLE works ADD COLUMN IF NOT EXISTS play_store_url TEXT;
ALTER TABLE works ADD COLUMN IF NOT EXISTS app_store_url TEXT;
ALTER TABLE works ADD COLUMN IF NOT EXISTS app_icon_url TEXT;

