-- Migration: Credit Purchase System (One-Time Purchase Model)
-- Description: Premium = credits > 0, no monthly billing
-- Date: 2025-12-09

-- Function to purchase credits (one-time payment)
CREATE OR REPLACE FUNCTION purchase_credits(
  p_user_id UUID,
  p_credits_amount INT,
  p_payment_id TEXT,
  p_amount_paid DECIMAL
)
RETURNS void AS $$
BEGIN
  -- Add purchased credits to user's balance
  UPDATE profiles
  SET credits_balance = credits_balance + p_credits_amount,
      updated_at = NOW()
  WHERE id = p_user_id;
  
  -- Record the purchase in subscriptions table (now used as purchase history)
  INSERT INTO subscriptions (
    user_id,
    stripe_subscription_id,
    tier,
    status,
    current_period_start,
    current_period_end
  ) VALUES (
    p_user_id,
    p_payment_id,
    'credit_purchase',
    'completed',
    NOW(),
    NULL  -- No expiry for purchased credits
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has premium access (credits > 0)
CREATE OR REPLACE FUNCTION has_premium_access(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  user_credits INT;
BEGIN
  SELECT credits_balance INTO user_credits
  FROM profiles
  WHERE id = p_user_id;
  
  RETURN COALESCE(user_credits, 0) > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to deduct credits when using a feature
CREATE OR REPLACE FUNCTION use_credit(
  p_user_id UUID,
  p_feature TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  current_credits INT;
BEGIN
  -- Get current credits
  SELECT credits_balance INTO current_credits
  FROM profiles
  WHERE id = p_user_id;
  
  -- Check if user has enough credits
  IF COALESCE(current_credits, 0) <= 0 THEN
    RETURN FALSE;
  END IF;
  
  -- Deduct 1 credit
  UPDATE profiles
  SET credits_balance = credits_balance - 1,
      updated_at = NOW()
  WHERE id = p_user_id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-set subscription_tier based on credits
CREATE OR REPLACE FUNCTION update_tier_based_on_credits()
RETURNS TRIGGER AS $$
BEGIN
  -- If credits > 0, set as premium, else free
  IF NEW.credits_balance > 0 THEN
    NEW.subscription_tier := 'premium';
    NEW.subscription_status := 'active';
  ELSE
    NEW.subscription_tier := 'free';
    NEW.subscription_status := 'inactive';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on profiles table
DROP TRIGGER IF EXISTS trigger_update_tier ON profiles;
CREATE TRIGGER trigger_update_tier
  BEFORE UPDATE OF credits_balance ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_tier_based_on_credits();

COMMENT ON FUNCTION purchase_credits IS 'One-time credit purchase - adds credits to user balance';
COMMENT ON FUNCTION has_premium_access IS 'Returns true if user has credits > 0 (premium access)';
COMMENT ON FUNCTION use_credit IS 'Deducts 1 credit and returns success status';
COMMENT ON TRIGGER trigger_update_tier ON profiles IS 'Auto-updates tier to premium when credits > 0';
