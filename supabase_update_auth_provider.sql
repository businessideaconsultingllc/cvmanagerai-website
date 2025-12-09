-- Update Supabase RPC Function to Include Auth Provider
-- This SQL script updates the get_all_users_with_credits function to include signup method information

-- Drop the existing function
DROP FUNCTION IF EXISTS get_all_users_with_credits();

-- Create the updated function with auth_provider field
CREATE OR REPLACE FUNCTION get_all_users_with_credits()
RETURNS TABLE (
  id uuid,
  email text,
  full_name text,
  first_name text,
  last_name text,
  phone text,
  address text,
  is_admin boolean,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  credits_balance integer,
  last_seen timestamp with time zone,
  auth_provider text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    au.email::text,
    (CASE 
      WHEN p.first_name IS NOT NULL AND p.last_name IS NOT NULL 
      THEN p.first_name || ' ' || p.last_name
      WHEN p.first_name IS NOT NULL 
      THEN p.first_name
      ELSE au.email
    END)::text as full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    p.is_admin,
    p.created_at,
    p.updated_at,
    p.credits_balance,
    p.last_seen,
    COALESCE(
      (SELECT provider FROM auth.identities WHERE auth.identities.user_id = p.id LIMIT 1),
      'email'
    ) as auth_provider
  FROM profiles p
  LEFT JOIN auth.users au ON p.id = au.id
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
