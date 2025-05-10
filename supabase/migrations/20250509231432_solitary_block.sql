/*
  # Update categories table for image storage

  1. Changes
    - Add image_url column to categories table
    - Add storage bucket for category images
    - Update icon column to be nullable (for migration)
  
  2. Storage
    - Create bucket for category images
    - Set up public access policy
*/

-- Create storage bucket for category images
INSERT INTO storage.buckets (id, name, public)
VALUES ('category-images', 'category-images', true);

-- Allow public access to the bucket
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'category-images');

-- Update categories table
ALTER TABLE categories
ADD COLUMN image_url text,
ALTER COLUMN icon DROP NOT NULL;