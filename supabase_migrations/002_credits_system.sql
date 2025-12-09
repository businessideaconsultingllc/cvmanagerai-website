-- Credits System Migration
-- Add credits columns to profiles table and create transactions table

-- Update profiles table with credits columns
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS credits_balance INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS credits_reset_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS total_credits_used INTEGER DEFAULT 0;

-- Create credit transactions table for tracking usage
CREATE TABLE IF NOT EXISTS credit_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  operation_type TEXT NOT NULL, -- 'generate_cv', 'optimize_cv', 'tailor_cv', 'cover_letter', 'ats_check', 'reset'
  credits_used INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user ON credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_created ON credit_transactions(created_at);

-- Enable RLS on credit_transactions
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own transactions
CREATE POLICY "Users can view own transactions"
  ON credit_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Service role can insert transactions (for backend operations)
CREATE POLICY "Service can insert transactions"
  ON credit_transactions
  FOR INSERT
  WITH CHECK (true);

-- Update existing users to have initial credits if null
UPDATE profiles
SET credits_balance = 5,
    credits_reset_date = CURRENT_TIMESTAMP,
    total_credits_used = 0
WHERE credits_balance IS NULL;
