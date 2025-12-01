-- ============================================================================
-- ONLINE USERS TRACKING - DATABASE MIGRATION
-- Add last_seen column to track user presence
-- ============================================================================

-- 1. Add last_seen column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS last_seen TIMESTAMPTZ DEFAULT NOW();

-- 2. Create index for faster online user queries
CREATE INDEX IF NOT EXISTS idx_profiles_last_seen ON profiles(last_seen);

-- 3. Set initial last_seen for existing users
UPDATE profiles 
SET last_seen = updated_at 
WHERE last_seen IS NULL;

-- 4. Add RLS policy to allow users to update their own last_seen
DROP POLICY IF EXISTS "Users can update own last_seen" ON profiles;

CREATE POLICY "Users can update own last_seen"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 5. Drop and recreate the get_all_users_with_credits function to include last_seen
-- (needed because we're changing the return type)
DROP FUNCTION IF EXISTS get_all_users_with_credits();

CREATE FUNCTION get_all_users_with_credits()
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  address TEXT,
  is_admin BOOLEAN,
  credits_balance INTEGER,
  created_at TIMESTAMPTZ,
  last_seen TIMESTAMPTZ
) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    au.email::TEXT,
    COALESCE(p.first_name || ' ' || p.last_name, p.first_name, p.last_name, au.email)::TEXT as full_name,
    p.first_name::TEXT,
    p.last_name::TEXT,
    p.phone::TEXT,
    p.address::TEXT,
    p.is_admin,
    p.credits_balance,
    p.created_at,
    p.last_seen
  FROM profiles p
  JOIN auth.users au ON p.id = au.id
  ORDER BY p.created_at DESC;
END;
$$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if last_seen column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name = 'last_seen';

-- Check if index was created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'profiles' AND indexname = 'idx_profiles_last_seen';

-- Test function returns last_seen
SELECT id, email, last_seen FROM get_all_users_with_credits() LIMIT 5;

-- ============================================================================
-- HOW TO USE:
-- 1. Open Supabase Dashboard
-- 2. Go to SQL Editor
-- 3. Paste this entire script
-- 4. Click "Run"
-- ============================================================================
