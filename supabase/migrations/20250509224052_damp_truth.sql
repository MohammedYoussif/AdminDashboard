/*
  # Add authentication requirements

  1. Changes
    - Add email constraint to users table
    - Add role validation check
    - Add trigger to sync auth.users role with users.role
    - Add function to handle user creation

  2. Security
    - Add role validation to ensure only 'admin' and 'user' roles are allowed
    - Add trigger to automatically create user record on auth signup
*/

-- Add email column and constraint
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS email text UNIQUE NOT NULL;

-- Add role validation
ALTER TABLE users 
ADD CONSTRAINT valid_role CHECK (role IN ('admin', 'user'));

-- Function to handle user creation and role management
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user record on auth signup
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW
      EXECUTE FUNCTION handle_new_user();
  END IF;
END $$;

-- Function to sync role changes
CREATE OR REPLACE FUNCTION sync_user_role()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    UPDATE auth.users
    SET raw_user_meta_data = 
      jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{role}',
        to_jsonb(NEW.role)
      )
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to sync role changes
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_user_role_update'
  ) THEN
    CREATE TRIGGER on_user_role_update
      AFTER UPDATE OF role ON public.users
      FOR EACH ROW
      EXECUTE FUNCTION sync_user_role();
  END IF;
END $$;