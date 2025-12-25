-- Add years_of_experience field to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS years_of_experience INTEGER;

