-- ==========================================
-- FIX ALL RLS POLICIES (Run this entire script)
-- ==========================================

-- 1. PROFILES: Allow users to view their own profile (Critical for Credits)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (
  auth.uid() = id
);

-- 2. PROFILES: Allow Admins to view ALL profiles (Critical for Admin Panel > Online Users)
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (
  (SELECT is_admin FROM public.profiles WHERE id = auth.uid()) = true
);

-- 3. USER ACTIVITIES: Allow insertion (Critical for "Generate/Optimize log not working")
DROP POLICY IF EXISTS "Users can insert their own activity" ON public.user_activities;
CREATE POLICY "Users can insert their own activity"
ON public.user_activities FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 4. USER ACTIVITIES: Allow admins to view (Critical for Admin Panel > Dashboard/Activities)
DROP POLICY IF EXISTS "Admins can view all activities" ON public.user_activities;
CREATE POLICY "Admins can view all activities"
ON public.user_activities FOR SELECT
TO authenticated
USING (
  (SELECT is_admin FROM public.profiles WHERE id = auth.uid()) = true
);

-- 5. CREDIT UPDATE: Allow Admin adjustments
-- (Optional, but good for "Adjust Credits" feature)
-- Ideally updates should be via Edge Function to be safe, but if doing direct DB update:
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
CREATE POLICY "Admins can update profiles"
ON public.profiles FOR UPDATE
TO authenticated
USING (
  (SELECT is_admin FROM public.profiles WHERE id = auth.uid()) = true
);
