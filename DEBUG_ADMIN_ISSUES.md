# Debug Admin Issues

## Issue Report
- Signing in with admin account shows errors
- Profile has errors
- Credits not showing
- Getting error messages

## Possible Causes

### 1. Database Schema Missing Fields
The admin setup might be missing the `email` field in the profiles table join.

### 2. Profile Not Created
The admin user might not have a profile entry in the profiles table.

### 3. Credit Transaction Issue
No initial credits given to the admin user.

## Solution Steps

### Step 1: Verify Profile Exists
Run this SQL in Supabase:
```sql
SELECT * FROM profiles WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'ahmadkassem511@gmail.com'
);
```

If no profile exists, create one:
```sql
INSERT INTO profiles (id, email, first_name, last_name, full_name, is_admin, created_at, updated_at)
SELECT 
  id,
  email,
  'Ahmad',
  'Kassem',
  'Ahmad Kassem',
  true,
  NOW(),
  NOW()
FROM auth.users 
WHERE email = 'ahmadkassem511@gmail.com'
ON CONFLICT (id) DO UPDATE
SET is_admin = true,
    email = EXCLUDED.email;
```

### Step 2: Give Initial Credits
```sql
INSERT INTO credit_transactions (user_id, amount, description, created_at)
SELECT 
  id,
  100,
  'Initial admin credits',
  NOW()
FROM auth.users 
WHERE email = 'ahmadkassem511@gmail.com';
```

### Step 3: Fix get_all_users_with_credits Function
The function needs to handle users without email in profiles table.

Run this updated function:
```sql
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
    COALESCE(p.email, au.email) as email,
    p.full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    COALESCE(p.is_admin, false) as is_admin,
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
```

### Step 4: Ensure Profiles Table Has Email Column
If the profiles table doesn't have an email column, add it:
```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Update existing profiles with email from auth.users
UPDATE profiles p
SET email = au.email
FROM auth.users au
WHERE p.id = au.id AND p.email IS NULL;
```

## Quick Fix Script
Run this complete script in Supabase SQL Editor:

```sql
-- 1. Add email column if missing
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. Update profiles with email from auth
UPDATE profiles p
SET email = au.email
FROM auth.users au
WHERE p.id = au.id AND p.email IS NULL;

-- 3. Ensure admin profile exists and is complete
INSERT INTO profiles (id, email, first_name, last_name, full_name, phone, address, is_admin, created_at, updated_at)
SELECT 
  id,
  email,
  'Ahmad',
  'Kassem',
  'Ahmad Kassem',
  '',
  '',
  true,
  NOW(),
  NOW()
FROM auth.users 
WHERE email = 'ahmadkassem511@gmail.com'
ON CONFLICT (id) DO UPDATE
SET 
  is_admin = true,
  email = EXCLUDED.email,
  first_name = COALESCE(profiles.first_name, EXCLUDED.first_name),
  last_name = COALESCE(profiles.last_name, EXCLUDED.last_name),
  full_name = COALESCE(profiles.full_name, EXCLUDED.full_name);

-- 4. Give initial credits if none exist
INSERT INTO credit_transactions (user_id, amount, description, created_at)
SELECT 
  id,
  100,
  'Initial admin credits',
  NOW()
FROM auth.users 
WHERE email = 'ahmadkassem511@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM credit_transactions 
  WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'ahmadkassem511@gmail.com')
);

-- 5. Update the get_all_users_with_credits function
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
    p.full_name,
    p.first_name,
    p.last_name,
    p.phone,
    p.address,
    COALESCE(p.is_admin, false) as is_admin,
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
```

## After Running the Script

1. Logout from the app
2. Login again with `ahmadkassem511@gmail.com`
3. The profile should work correctly
4. Credits should show 100
5. Admin panel should be accessible

## If Errors Persist

Please share:
1. The exact error message from the app
2. Screenshot of the Supabase profiles table
3. Result of running: `SELECT * FROM profiles WHERE is_admin = true;`
