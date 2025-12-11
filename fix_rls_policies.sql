-- ============================================
-- FIX RLS POLICIES - Run this to fix 500 errors
-- The current RLS policies are blocking all access
-- ============================================

-- Step 1: Drop all existing policies on profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON profiles;

-- Step 2: Create simple, permissive policies
-- Allow users to read their own profile
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"  
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Step 3: Fix credit_transactions policies
DROP POLICY IF EXISTS "Admins can view all credit transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Admins can insert credit transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Users can view own transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Enable read access for all users" ON credit_transactions;

-- Allow users to view their own transactions
CREATE POLICY "Users can view own transactions"
ON credit_transactions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Allow users to insert their own transactions
CREATE POLICY "Users can insert own transactions"
ON credit_transactions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Step 4: Ensure admin user exists and has data
-- This will update or create the admin profile
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
  updated_at = NOW();

-- Step 5: Verify setup
SELECT 
  p.id,
  p.email,
  p.first_name,
  p.last_name,
  p.is_admin,
  p.credits_balance
FROM profiles p
WHERE p.email = 'ahmadkassem511@gmail.com';

-- You should see your profile with is_admin = true and credits_balance >= 100
