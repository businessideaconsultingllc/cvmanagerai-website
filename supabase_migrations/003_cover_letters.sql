-- Cover Letter Generation Migration

-- Create cover_letters table
CREATE TABLE IF NOT EXISTS cover_letters (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  job_title TEXT,
  company_name TEXT,
  job_description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for user_id
CREATE INDEX IF NOT EXISTS idx_cover_letters_user ON cover_letters(user_id);

-- Enable RLS
ALTER TABLE cover_letters ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own cover letters"
  ON cover_letters FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cover letters"
  ON cover_letters FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cover letters"
  ON cover_letters FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cover letters"
  ON cover_letters FOR DELETE
  USING (auth.uid() = user_id);
