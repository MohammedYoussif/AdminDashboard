/*
  # Add created_at column to categories table

  1. Changes
    - Add `created_at` timestamp column to categories table with default value
    - Backfill existing rows with current timestamp
*/

-- Add created_at column with default value
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- Update any existing rows that might not have created_at set
UPDATE categories 
SET created_at = now() 
WHERE created_at IS NULL;