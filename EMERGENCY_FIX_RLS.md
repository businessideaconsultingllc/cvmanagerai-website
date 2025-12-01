# CRITICAL ISSUE: Database RLS Policies Blocking Access

## Problem
All Supabase queries are returning **500 errors** - the RLS (Row Level Security) policies are blocking ALL access to the `profiles` table, even for users trying to view their own profile.

## What Happened
1. The admin setup SQL added strict RLS policies
2. These policies are TOO restrictive and block normal user access
3. This is causing all profile queries to fail with 500 errors
4. The app cannot load user data, credits, or anything else

## IMMEDIATE FIX REQUIRED

### Run this SQL in Supabase SQL Editor:

```sql
-- ============================================
-- EMERGENCY FIX: Remove blocking RLS policies
-- ============================================

-- Step 1: Drop ALL existing policies on profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON profiles;

--  Step 2: Create SIMPLE policies that actually work
CREATE POLICY "authenticated_users_view_own_profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "authenticated_users_update_own_profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "authenticated_users_insert_own_profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Step 3: Fix credit_transactions policies
DROP POLICY IF EXISTS "Admins can view all credit transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Admins can insert credit transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Users can view own transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Enable read access for all users" ON credit_transactions;

CREATE POLICY "users_view_own_transactions"
ON credit_transactions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "users_insert_own_transactions"
ON credit_transactions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Step 4: Add admin user with 100 credits
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
```

## After Running the SQL

1. **Restart the Flutter app** (or hot restart with `R`)
2. **Logout and login again**
3. The 500 errors should be gone
4. Profile and credits should load correctly

## Why This Happened

The initial admin setup scripts tried to add admin access checks like:
```sql
EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE)
```

But these checks BLOCKED normal users from accessing their own data because the policies were applied to ALL access, not just admin operations.

## Next Steps After Fix

Once the 500 errors are resolved:
1. I'll restore the router file (it got corrupted)
2. We'll add the admin panel back properly
3. Test that everything works

**Please run the SQL script above NOW to fix the blocking issue!**
