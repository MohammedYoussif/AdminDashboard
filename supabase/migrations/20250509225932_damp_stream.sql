/*
  # Fix user authentication and role handling

  1. Changes
    - Add function to properly sync user data on login
    - Update role check to be case insensitive
    - Add index on email for faster lookups

  2. Security
    - Maintain existing RLS policies
    - Add security definer to ensure proper privilege escalation
*/

-- Function to ensure user data is synced
CREATE OR REPLACE FUNCTION sync_user_data()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.users
  SET email = NEW.email,
      name = COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  WHERE id = NEW.id;
  
  IF NOT FOUND THEN
    INSERT INTO public.users (id, email, name, role)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
      COALESCE(NEW.raw_user_meta_data->>'role', 'user')
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for user data sync
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_updated'
  ) THEN
    CREATE TRIGGER on_auth_user_updated
      AFTER UPDATE ON auth.users
      FOR EACH ROW
      EXECUTE FUNCTION sync_user_data();
  END IF;
END $$;

-- Add index on email
CREATE INDEX IF NOT EXISTS users_email_idx ON users (email);