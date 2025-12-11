-- Add cv_type column to cvs table
-- This allows categorization of CVs as generated, optimized, or tailored

ALTER TABLE cvs 
ADD COLUMN cv_type TEXT DEFAULT 'generated' CHECK (cv_type IN ('generated', 'optimized', 'tailored'));

-- Update existing CVs to have 'generated' type
UPDATE cvs SET cv_type = 'generated' WHERE cv_type IS NULL;

-- Add index for better query performance
CREATE INDEX idx_cvs_cv_type ON cvs(cv_type);
CREATE INDEX idx_cvs_user_id_cv_type ON cvs(user_id, cv_type);
