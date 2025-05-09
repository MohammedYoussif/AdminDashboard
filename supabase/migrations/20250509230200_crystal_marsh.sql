/*
  # Fix user authentication schema

  1. Changes
    - Add case-insensitive email index for better lookup performance
    - Add case-insensitive role index
    - Update role check constraint to be case insensitive

  2. Security
    - Maintain existing RLS policies
    - Ensure data integrity with proper constraints
*/

-- Drop existing case-sensitive index if it exists
DROP INDEX IF EXISTS users_email_idx;

-- Create case-insensitive email index
CREATE INDEX IF NOT EXISTS users_email_lower_idx ON users (LOWER(email));

-- Create case-insensitive role index
CREATE INDEX IF NOT EXISTS users_role_lower_idx ON users (LOWER(role));

-- Update role check constraint to be case insensitive
ALTER TABLE users 
DROP CONSTRAINT IF EXISTS valid_role;

ALTER TABLE users 
ADD CONSTRAINT valid_role CHECK (LOWER(role) IN ('admin', 'user'));