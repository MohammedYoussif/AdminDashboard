/*
  # Add created_at column to users table

  1. Changes
    - Add `created_at` timestamp column to users table with default value
    - Backfill existing rows with current timestamp
*/

-- Add created_at column with default value
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- Update any existing rows that might not have created_at set
UPDATE users 
SET created_at = now() 
WHERE created_at IS NULL;