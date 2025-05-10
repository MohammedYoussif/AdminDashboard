/*
  # Update categories table and add cleanup function

  1. Changes
    - Remove user_count column from categories table
    - Add function to clean up storage when deleting categories

  2. Security
    - Maintain existing RLS policies
*/

-- Remove user_count column
ALTER TABLE categories DROP COLUMN IF EXISTS user_count;

-- Create function to extract filename from URL
CREATE OR REPLACE FUNCTION get_filename_from_url(url text)
RETURNS text AS $$
BEGIN
    RETURN substring(url from '/([^/]+)$');
END;
$$ LANGUAGE plpgsql;

-- Create function to delete storage object before category deletion
CREATE OR REPLACE FUNCTION delete_category_image()
RETURNS trigger AS $$
BEGIN
    -- Delete the image from storage if it exists
    IF OLD.image_url IS NOT NULL THEN
        DELETE FROM storage.objects
        WHERE bucket_id = 'category-images'
        AND name = get_filename_from_url(OLD.image_url);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically delete image when category is deleted
DROP TRIGGER IF EXISTS delete_category_image_trigger ON categories;
CREATE TRIGGER delete_category_image_trigger
    BEFORE DELETE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION delete_category_image();