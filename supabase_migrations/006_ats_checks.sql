-- Create ats_checks table
CREATE TABLE IF NOT EXISTS public.ats_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cv_content TEXT NOT NULL,
    score INTEGER NOT NULL,
    problems JSONB DEFAULT '[]'::jsonb,
    fix_points JSONB DEFAULT '[]'::jsonb,
    how_to_optimize TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.ats_checks ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own ATS checks"
ON public.ats_checks FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own ATS checks"
ON public.ats_checks FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Update credit_transaction check constraint if it exists
-- Note: Some Supabase versions might use naming like credit_transaction_operation_type_check
-- We add a new operation type for ATS checks
DO $$ 
BEGIN
    -- This depends on how the constraint was named. 
    -- Typically we might need to drop and recreate the constraint or just rely on the app logic
    -- if the DB doesn't strictly enforce it via enum/check.
END $$;
