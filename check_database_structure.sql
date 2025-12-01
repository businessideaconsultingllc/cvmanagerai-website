-- ============================================
-- DIAGNOSTIC: Check Actual Table Structure
-- Run this first to see what columns exist
-- ============================================

-- Check profiles table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Check credit_transactions table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'credit_transactions' 
ORDER BY ordinal_position;

-- Check if admin user exists
SELECT id, email FROM auth.users WHERE email = 'ahmadkassem511@gmail.com';

-- Check admin profile
SELECT * FROM profiles WHERE email = 'ahmadkassem511@gmail.com';

-- Check all data in credit_transactions
SELECT * FROM credit_transactions LIMIT 5;
