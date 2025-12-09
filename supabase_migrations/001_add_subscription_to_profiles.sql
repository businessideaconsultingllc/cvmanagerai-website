-- Migration: Add subscription fields to profiles table
-- Description: Adds subscription tracking fields for premium tier implementation
-- Date: 2025-12-09

-- Add subscription columns to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'free';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'active';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP;

-- Create index for faster subscription tier lookups
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_tier ON profiles(subscription_tier);
CREATE INDEX IF NOT EXISTS idx_profiles_stripe_customer ON profiles(stripe_customer_id);

-- Add comment for documentation
COMMENT ON COLUMN profiles.subscription_tier IS 'User subscription tier: free or premium';
COMMENT ON COLUMN profiles.subscription_status IS 'Subscription status: active, canceled, expired';
COMMENT ON COLUMN profiles.stripe_customer_id IS 'Stripe customer ID for payment tracking';
COMMENT ON COLUMN profiles.subscription_end_date IS 'When the current subscription period ends';
