/*
  # Update policies to check roles from users table

  1. Changes
    - Drop existing policies
    - Create new policies that join with users table
    - Use case-insensitive role comparison

  2. Security
    - Policies now check role from users table
    - Maintain same access levels but with proper role verification
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
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can insert users"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can update users"
  ON users
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can delete users"
  ON users
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

-- Create new policies for categories table
CREATE POLICY "Admin users can read all categories"
  ON categories
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can insert categories"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can update categories"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

CREATE POLICY "Admin users can delete categories"
  ON categories
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND LOWER(u.role) = 'admin'
    )
  );

-- Update storage policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'category-images' AND
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND LOWER(u.role) = 'admin'
  )
);

CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'category-images' AND
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND LOWER(u.role) = 'admin'
  )
)
WITH CHECK (
  bucket_id = 'category-images' AND
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND LOWER(u.role) = 'admin'
  )
);

CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'category-images' AND
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND LOWER(u.role) = 'admin'
  )
);