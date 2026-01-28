-- VERIFY AND FIX RLS FOR ADMIN DATA ACCESS

-- 1. Ensure the is_admin function is robust and security definer
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    _is_admin BOOLEAN;
BEGIN
    SELECT is_admin INTO _is_admin
    FROM public.profiles
    WHERE id = auth.uid();
    
    RETURN COALESCE(_is_admin, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Grant necessary permissions to the function
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO service_role;

-- 3. Ensure profiles are visible to admins (CRITICAL for joins)
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT TO authenticated
USING (public.is_admin());

-- 4. Ensure user_activities and user_feedback are visible to admins
DROP POLICY IF EXISTS "Admins can view all activities" ON public.user_activities;
CREATE POLICY "Admins can view all activities"
ON public.user_activities FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all feedback" ON public.user_feedback;
CREATE POLICY "Admins can view all feedback"
ON public.user_feedback FOR SELECT TO authenticated
USING (public.is_admin());

-- 5. Final check: verify if the current user profile has an email (important for display)
-- UPDATE public.profiles SET email = 'ahmadkassem511@gmail.com' WHERE id = '...'; -- If manual fix needed
