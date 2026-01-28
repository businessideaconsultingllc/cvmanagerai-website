-- =====================================================
-- CV Master AI - Comprehensive Admin & Database Control
-- =====================================================
-- This script sets up notifications, stats, and management
-- Execute this in your Supabase SQL Editor
-- =====================================================

-- 1. Create admin_notifications table
CREATE TABLE IF NOT EXISTS public.admin_notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL, -- e.g., 'new_user'
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies for admin access
DROP POLICY IF EXISTS "Admins can view notifications" ON public.admin_notifications;
CREATE POLICY "Admins can view notifications" ON public.admin_notifications
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

DROP POLICY IF EXISTS "Admins can update notifications" ON public.admin_notifications;
CREATE POLICY "Admins can update notifications" ON public.admin_notifications
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- 4. Create function to handle new user notification
CREATE OR REPLACE FUNCTION public.handle_new_user_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- We use COALESCE to handle cases where email might be missing temporarily
  INSERT INTO public.admin_notifications (type, message, data)
  VALUES (
    'new_user',
    'New user signup: ' || COALESCE(NEW.email, 'User ' || NEW.id),
    jsonb_build_object(
      'user_id', NEW.id,
      'email', NEW.email,
      'full_name', NEW.full_name
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Create trigger for new user notification
DROP TRIGGER IF EXISTS on_profile_created_notification ON public.profiles;
CREATE TRIGGER on_profile_created_notification
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user_notification();

-- 6. Enable real-time for admin_notifications table
-- Note: You might need to check if the publication 'supabase_realtime' exists or adapt it
-- ALTER PUBLICATION supabase_realtime ADD TABLE admin_notifications;

-- 7. Add is_suspended to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE;

-- 8. Create a function to get system statistics
CREATE OR REPLACE FUNCTION public.get_system_stats()
RETURNS JSONB
SECURITY DEFINER
AS $$
DECLARE
  result JSONB;
BEGIN
  -- Check if the calling user is an admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND is_admin = TRUE
  ) THEN
    RAISE EXCEPTION 'Only admins can access this function';
  END IF;

  SELECT jsonb_build_object(
    'total_users', (SELECT count(*) FROM profiles),
    'total_cvs', (SELECT count(*) FROM cvs),
    'total_cover_letters', (SELECT count(*) FROM cover_letters),
    'total_credits', (SELECT COALESCE(sum(credits_balance), 0) FROM profiles),
    'active_users_24h', (SELECT count(*) FROM profiles WHERE last_seen > now() - interval '24 hours'),
    'new_users_7d', (SELECT count(*) FROM profiles WHERE created_at > now() - interval '7 days')
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 9. Grant execute permission on stats function
GRANT EXECUTE ON FUNCTION public.get_system_stats() TO authenticated;

-- =====================================================
-- Setup Complete!
-- =====================================================
