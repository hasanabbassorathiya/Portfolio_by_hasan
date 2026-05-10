-- Add missing columns to works table
ALTER TABLE works ADD COLUMN IF NOT EXISTS play_store_url TEXT;
ALTER TABLE works ADD COLUMN IF NOT EXISTS app_store_url TEXT;
ALTER TABLE works ADD COLUMN IF NOT EXISTS app_icon_url TEXT;
-- Ensure client exists (in case it was somehow dropped)
ALTER TABLE works ADD COLUMN IF NOT EXISTS client TEXT;
