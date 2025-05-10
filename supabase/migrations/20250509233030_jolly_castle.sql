/*
  # Update RLS policies for admin checks and public read access

  1. Changes
    - Allow all authenticated users to read (SELECT) from tables
    - Check admin status from users table for write operations
    - Update storage policies to use users table for admin checks

  2. Security
    - Maintain strict admin-only write access
    - Enable read access for all authenticated users
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
CREATE POLICY "Authenticated users can read users"
  ON users
  FOR SELECT
  TO authenticated
  USING (true);

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
CREATE POLICY "Authenticated users can read categories"
  ON categories
  FOR SELECT
  TO authenticated
  USING (true);

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