/*
  # Fix storage policies for category images

  1. Security
    - Add policies for authenticated users to upload and delete images
    - Ensure only admin users can manage images
*/

-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');

-- Allow authenticated users to update files
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin')
WITH CHECK (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');

-- Allow authenticated users to delete files
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'category-images' AND auth.jwt() ->> 'role' = 'admin');