-- =========================================================
-- ULTIMATE FIX: SECURITY DEFINER FUNCTIONS (RLS SAFE)
-- This bypasses RLS recursion issues on the profiles table.
-- =========================================================

-- 1. Create a secure function to check admin status
-- SECURITY DEFINER allows the function to bypass RLS for its internal query
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
    AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. FIX PROFILES TABLE POLICIES
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- Allow users to see their own profile (Critical for credits)
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Allow admins to see all profiles (Non-recursive)
CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (public.is_admin());

-- 3. FIX USER_ACTIVITIES TABLE POLICIES
DROP POLICY IF EXISTS "Users can insert their own activity" ON public.user_activities;
DROP POLICY IF EXISTS "Admins can view all activities" ON public.user_activities;

CREATE POLICY "Users can insert their own activity"
ON public.user_activities FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all activities"
ON public.user_activities FOR SELECT
TO authenticated
USING (public.is_admin());

-- 4. FIX USER_FEEDBACK TABLE POLICIES
DROP POLICY IF EXISTS "Admins can view all feedback" ON public.user_feedback;
DROP POLICY IF EXISTS "Admins can update feedback" ON public.user_feedback;
DROP POLICY IF EXISTS "Users can insert feedback" ON public.user_feedback;

CREATE POLICY "Users can insert feedback"
ON public.user_feedback FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all feedback"
ON public.user_feedback FOR SELECT
TO authenticated
USING (public.is_admin());

CREATE POLICY "Admins can update feedback"
ON public.user_feedback FOR UPDATE
TO authenticated
USING (public.is_admin());
