-- =====================================================
-- CV Master AI - Admin Panel Setup Script
-- =====================================================
-- This script sets up the admin panel functionality
-- Execute this in your Supabase SQL Editor
-- =====================================================

-- 1. Add is_admin column to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. Set admin user (ahmadkassem511@gmail.com)
-- This will set the user as admin based on their email
UPDATE profiles
SET is_admin = TRUE
WHERE email = 'ahmadkassem511@gmail.com';

-- If the email field doesn't exist in profiles, use this alternative:
-- UPDATE profiles
-- SET is_admin = TRUE
-- WHERE id IN (
--   SELECT id FROM auth.users WHERE email = 'ahmadkassem511@gmail.com'
-- );

-- 3. Create RLS policy for admin access to view all profiles
CREATE POLICY "Admins can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = TRUE
  )
  OR profiles.id = auth.uid()  -- Users can still view their own profile
);

-- 4. Create RLS policy for admin to update any profile
CREATE POLICY "Admins can update all profiles"
ON profiles FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = TRUE
  )
  OR profiles.id = auth.uid()  -- Users can still update their own profile
);

-- 5. Create RLS policy for admin to delete profiles
CREATE POLICY "Admins can delete profiles"
ON profiles FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = TRUE
  )
  AND profiles.id != auth.uid()  -- Prevent admin from deleting themselves
);

-- 6. RLS policy for admin access to credit transactions
-- First, check if this policy already exists, if so, drop it
DROP POLICY IF EXISTS "Admins can view all credit transactions" ON credit_transactions;

CREATE POLICY "Admins can view all credit transactions"
ON credit_transactions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = TRUE
  )
  OR credit_transactions.user_id = auth.uid()  -- Users can view their own transactions
);

-- 7. RLS policy for admin to insert credit transactions
DROP POLICY IF EXISTS "Admins can insert credit transactions" ON credit_transactions;

CREATE POLICY "Admins can insert credit transactions"
ON credit_transactions FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = TRUE
  )
);

-- 8. Create a function to get all users with their credit balance
-- This will be useful for the admin panel
CREATE OR REPLACE FUNCTION get_all_users_with_credits()
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  address TEXT,
  is_admin BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  credit_balance INTEGER
) 
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the calling user is an admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.is_admin = TRUE
  ) THEN
    RAISE EXCEPTION 'Only admins can access this function';
  END IF;

  -- Return all users with their credit balance
  RETURN QUERY
  SELECT 
    p.id,
    au.email,
    p.full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    p.is_admin,
    p.created_at,
    p.updated_at,
    COALESCE(
      (SELECT SUM(amount) 
       FROM credit_transactions 
       WHERE user_id = p.id), 
      0
    )::INTEGER as credit_balance
  FROM profiles p
  LEFT JOIN auth.users au ON p.id = au.id
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- 9. Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_all_users_with_credits() TO authenticated;

-- =====================================================
-- Setup Complete!
-- =====================================================
-- Next steps:
-- 1. Verify that ahmadkassem511@gmail.com is set as admin
-- 2. Test the admin panel in the Flutter app
-- =====================================================

-- To verify admin setup, run this query:
-- SELECT id, email, full_name, is_admin 
-- FROM profiles p
-- LEFT JOIN auth.users au ON p.id = au.id
-- WHERE is_admin = TRUE;
