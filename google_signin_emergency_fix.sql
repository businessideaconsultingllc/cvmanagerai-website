-- EMERGENCY FIX: RESTORE SIGNUP / GOOGLE SIGN-IN
-- This fixes the "Database error saving new user" error

-- 1. Ensure all columns exist (Safely)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_admin') THEN
        ALTER TABLE public.profiles ADD COLUMN is_admin BOOLEAN DEFAULT FALSE;
    END IF;
    -- Credits balance usually exists, but let's be safe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'credits_balance') THEN
        ALTER TABLE public.profiles ADD COLUMN credits_balance INTEGER DEFAULT 3;
    END IF;
END $$;

-- 2. Fix the trigger function to use CORRECT columns (first_name, last_name)
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    email, 
    first_name, 
    last_name, 
    is_admin, 
    credits_balance
  )
  VALUES (
    NEW.id, 
    NEW.email, 
    '',
    '',
    FALSE,
    3
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Ensure the trigger is active
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Sync your admin status again just in case
UPDATE public.profiles 
SET is_admin = TRUE 
WHERE email = 'ahmadkassem511@gmail.com';

-- 5. Fix the get_all_users function to use existing columns
-- (This ensures the Admin Panel works even if full_name column is missing)
DROP FUNCTION IF EXISTS get_all_users_with_credits();
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
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.email,
    COALESCE(p.first_name || ' ' || p.last_name, p.first_name, p.last_name, '') as full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    COALESCE(p.is_admin, false) as is_admin,
    p.created_at,
    p.updated_at,
    COALESCE(p.credits_balance, 0)::INTEGER as credit_balance
  FROM public.profiles p
  ORDER BY p.created_at DESC;
END;
$$;

-- 6. OPTIONAL: Reset a test user's profile to re-trigger the "Setup Profile" page
-- Uncomment and change the email below to test the redirect again
-- UPDATE public.profiles SET first_name = '', last_name = '' WHERE email = 'testuser@example.com';
