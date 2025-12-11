-- ============================================
-- SIMPLE FIX: ADMIN PROFILE & CREDITS
-- Run each section separately if needed
-- ============================================

-- SECTION 1: Add missing columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- SECTION 2: Sync emails
UPDATE profiles p
SET email = au.email
FROM auth.users au
WHERE p.id = au.id AND (p.email IS NULL OR p.email = '');

-- SECTION 3: Create/update admin profile with 100 credits
INSERT INTO profiles (id, email, first_name, last_name, phone, address, is_admin, credits_balance, created_at, updated_at)
SELECT 
  au.id,
  au.email,
  'Ahmad',
  'Kassem',
  '',
  '',
  true,
  100,
  NOW(),
  NOW()
FROM auth.users au
WHERE au.email = 'ahmadkassem511@gmail.com'
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  is_admin = true,
  credits_balance = GREATEST(profiles.credits_balance, 100),
  first_name = COALESCE(profiles.first_name, EXCLUDED.first_name),
  last_name = COALESCE(profiles.last_name, EXCLUDED.last_name),
  updated_at = NOW();

-- SECTION 4: Log initial transaction (run separately if needed)
INSERT INTO credit_transactions (user_id, operation_type, credits_used, balance_after, created_at)
SELECT 
  au.id,
  'admin_init',
  -100,
  100,
  NOW()
FROM auth.users au
WHERE au.email = 'ahmadkassem511@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM credit_transactions ct 
  WHERE ct.user_id = au.id AND ct.operation_type = 'admin_init'
);

-- SECTION 5: Admin view all profiles policy
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" 
ON profiles FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE)
  OR id = auth.uid()
);

-- SECTION 6: Admin update profiles policy
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
CREATE POLICY "Admins can update all profiles" 
ON profiles FOR UPDATE 
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE)
  OR id = auth.uid()
);

-- SECTION 7: Admin delete profiles policy
DROP POLICY IF EXISTS "Admins can delete profiles" ON profiles;
CREATE POLICY "Admins can delete profiles" 
ON profiles FOR DELETE 
USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = TRUE)
  AND id != auth.uid()
);

-- SECTION 8: Admin view credit transactions policy
DROP POLICY IF EXISTS "Admins can view all credit transactions" ON credit_transactions;
CREATE POLICY "Admins can view all credit transactions" 
ON credit_transactions FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE)
  OR user_id = auth.uid()
);

-- SECTION 9: Admin insert credit transactions policy
DROP POLICY IF EXISTS "Admins can insert credit transactions" ON credit_transactions;
CREATE POLICY "Admins can insert credit transactions" 
ON credit_transactions FOR INSERT 
WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE)
  OR user_id = auth.uid()
);

-- SECTION 10: Get all users function
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
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.is_admin = TRUE
  ) THEN
    RAISE EXCEPTION 'Only admins can access this function';
  END IF;

  RETURN QUERY
  SELECT 
    p.id,
    COALESCE(p.email, au.email) as email,
    COALESCE(p.first_name || ' ' || p.last_name, p.first_name, p.last_name, '') as full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    COALESCE(p.is_admin, false) as is_admin,
    p.created_at,
    p.updated_at,
    COALESCE(p.credits_balance, 0)::INTEGER as credit_balance
  FROM profiles p
  LEFT JOIN auth.users au ON p.id = au.id
  ORDER BY p.created_at DESC;
END;
$$;

-- SECTION 11: Verify setup
SELECT 
  p.id,
  p.email,
  p.first_name || ' ' || p.last_name as full_name,
  p.is_admin,
  p.credits_balance
FROM profiles p
WHERE p.email = 'ahmadkassem511@gmail.com';

-- You should see:
-- is_admin: true
-- credits_balance: 100
-- full_name: Ahmad Kassem
