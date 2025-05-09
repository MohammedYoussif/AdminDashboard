/*
  # Initial schema setup

  1. New Tables
    - `users`
      - `id` (uuid, primary key) - matches auth.users.id
      - `name` (text)
      - `role` (text)
      - `last_active` (timestamptz)
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text)
      - `icon` (text)
      - `user_count` (integer)

  2. Security
    - Enable RLS on all tables
    - Add policies for admin access
*/

-- Create users table that extends auth.users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  name text NOT NULL,
  role text NOT NULL DEFAULT 'user',
  last_active timestamptz DEFAULT now()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  icon text NOT NULL,
  user_count integer DEFAULT 0
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Policies for users table
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

-- Policies for categories table
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