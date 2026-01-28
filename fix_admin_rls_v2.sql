-- Allow admins to view all profiles
-- This is crucial for "Online Users" list and viewing user details
CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (
  (SELECT is_admin FROM public.profiles WHERE id = auth.uid()) = true
);

-- Ensure authenticated users can view their own profile (usually exists, but good to ensure)
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (
  auth.uid() = id
);

-- Verify user_activities policy exists (idempotent check not easy here without do block, 
-- but we can recreate or assume user runs this to fix)
-- Ensure user_activities insert policy is correct
DROP POLICY IF EXISTS "Users can insert their own activity" ON public.user_activities;
CREATE POLICY "Users can insert their own activity"
ON public.user_activities FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
