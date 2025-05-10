/*
  # Fix infinite recursion in RLS policies

  1. Changes
    - Update policies to check roles from JWT claims
    - Remove recursive user table queries
    - Simplify policy conditions

  2. Security
    - Maintain same access levels
    - Use JWT claims for role verification
    - Remove potential for infinite recursion
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Admin users can read all users" ON users;
DROP POLICY IF EXISTS "Admin users can insert users" ON users;
DROP POLICY IF EXISTS "Admin users can update users" ON users;
DROP POLICY IF EXISTS "Admin users can delete users" ON users;
DROP POLICY IF EXISTS "Admin users can read all categories" ON categories;
DROP POLICY IF EXISTS "Admin users can insert categories" ON categories;
DROP POLICY IF EXISTS "Admin users can update categories" ON categories;
DROP POLICY IF EXISTS "Admin users can delete categories" ON categories;

-- Create new policies for users table
CREATE POLICY "Admin users can read all users"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can insert users"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can update users"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can delete users"
  ON users
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

-- Create new policies for categories table
CREATE POLICY "Admin users can read all categories"
  ON categories
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can insert categories"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can update categories"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin users can delete categories"
  ON categories
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');

-- Update storage policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin')
WITH CHECK (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');