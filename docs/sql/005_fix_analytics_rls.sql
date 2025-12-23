-- Fix Analytics Summary RLS Policy
-- The trigger function needs to be able to INSERT into analytics_summary
-- This migration fixes the RLS policy violation

-- Option 1: Make the function run with elevated privileges (SECURITY DEFINER)
-- This allows the function to bypass RLS when inserting
CREATE OR REPLACE FUNCTION update_analytics_summary()
RETURNS TRIGGER 
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
BEGIN
  INSERT INTO analytics_summary (date, page_path, view_count)
  VALUES (CURRENT_DATE, NEW.page_path, 1)
  ON CONFLICT (date, page_path)
  DO UPDATE SET view_count = analytics_summary.view_count + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Option 2: Add an INSERT policy for the trigger (alternative approach)
-- Allow the function to insert (it runs as the database user, not the app user)
DROP POLICY IF EXISTS "Allow trigger to insert analytics summary" ON analytics_summary;
CREATE POLICY "Allow trigger to insert analytics summary"
  ON analytics_summary FOR INSERT
  WITH CHECK (true);

-- Note: The SECURITY DEFINER approach (Option 1) is more secure as it only
-- allows the specific function to insert, not any user.

