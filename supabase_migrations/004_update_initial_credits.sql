-- SQL to update initial credits from 5 to 3 for new users
-- Run this in Supabase SQL Editor

-- 1. Update the trigger that sets initial credits for new signups
CREATE OR REPLACE FUNCTION handle_new_user_signup()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, credits_balance, subscription_tier, subscription_status)
  VALUES (
    NEW.id,
    NEW.email,
    3,  -- Changed from 5 to 3 credits
    'free',
    'active'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. (Optional) Update existing users to 3 credits if they still have the default 5
-- ONLY run this if you want to reset existing users to 3 credits
-- Comment out if you don't want to change existing users

-- UPDATE profiles 
-- SET credits_balance = 3 
-- WHERE credits_balance = 5 
-- AND subscription_tier = 'free';

-- 3. Verify the change
SELECT email, credits_balance, subscription_tier 
FROM profiles 
ORDER BY created_at DESC 
LIMIT 10;
