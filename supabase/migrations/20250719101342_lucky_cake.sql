/*
  # Update profiles table for real-world usage

  1. New Columns
    - `username` (text, unique) - User's unique username
    - `phone` (text) - User's phone number
    - `date_of_birth` (date) - User's date of birth
    - `bio` (text) - User's bio/description
    - `address` (jsonb) - User's address information
    - `preferences` (jsonb) - User preferences and settings

  2. Security
    - Update RLS policies for new columns
    - Add username uniqueness constraint

  3. Indexes
    - Add index on username for fast lookups
*/

-- Add new columns to profiles table
DO $$
BEGIN
  -- Add username column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'username'
  ) THEN
    ALTER TABLE profiles ADD COLUMN username text UNIQUE;
  END IF;

  -- Add phone column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'phone'
  ) THEN
    ALTER TABLE profiles ADD COLUMN phone text;
  END IF;

  -- Add date_of_birth column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'date_of_birth'
  ) THEN
    ALTER TABLE profiles ADD COLUMN date_of_birth date;
  END IF;

  -- Add bio column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'bio'
  ) THEN
    ALTER TABLE profiles ADD COLUMN bio text;
  END IF;

  -- Add address column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'address'
  ) THEN
    ALTER TABLE profiles ADD COLUMN address jsonb DEFAULT '{}'::jsonb;
  END IF;

  -- Add preferences column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'preferences'
  ) THEN
    ALTER TABLE profiles ADD COLUMN preferences jsonb DEFAULT '{}'::jsonb;
  END IF;
END $$;

-- Create index on username for fast lookups
CREATE INDEX IF NOT EXISTS profiles_username_idx ON profiles(username);

-- Update RLS policies
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Add policy for username uniqueness check
CREATE POLICY "Anyone can check username availability"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);