-- 1. Extend profiles table with student metadata

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS student_id TEXT UNIQUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS semester TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS academic_year TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS dob DATE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;

-- 2. Create student_assignments table
CREATE TABLE IF NOT EXISTS public.student_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  student_id TEXT NOT NULL, -- Student's College ID (e.g., 23CS070)
  semester TEXT NOT NULL,
  academic_year TEXT NOT NULL,
  village_name TEXT NOT NULL,
  posting_start_date DATE NOT NULL,
  posting_end_date DATE NOT NULL,
  assigned_by UUID REFERENCES public.profiles(id)
);

-- Enable RLS on assignments
ALTER TABLE public.student_assignments ENABLE ROW LEVEL SECURITY;

-- Disable RLS restrictiveness or create policies to allow operations
DROP POLICY IF EXISTS "Anyone can view assignments" ON public.student_assignments;
CREATE POLICY "Anyone can view assignments" ON public.student_assignments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can create assignments" ON public.student_assignments;
CREATE POLICY "Anyone can create assignments" ON public.student_assignments FOR INSERT WITH CHECK (true);

-- 3. Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  student_id TEXT NOT NULL, -- Student's College ID (e.g., 23CS070)
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE NOT NULL
);

-- Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view notifications" ON public.notifications;
CREATE POLICY "Anyone can view notifications" ON public.notifications FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can create notifications" ON public.notifications;
CREATE POLICY "Anyone can create notifications" ON public.notifications FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Anyone can update notifications" ON public.notifications;
CREATE POLICY "Anyone can update notifications" ON public.notifications FOR UPDATE USING (true);

-- 4. Create trigger to sync profile changes back to auth.users metadata (for promotion sync)
CREATE OR REPLACE FUNCTION public.sync_profile_to_auth_users()
RETURNS TRIGGER AS $$
DECLARE
  v_course_name TEXT;
BEGIN
  IF NEW.role = 'student' THEN
    IF NEW.semester = '5th Sem' THEN
      v_course_name := 'NUR 303 - Community Health Nursing - I';
    ELSIF NEW.semester = '7th Sem' THEN
      v_course_name := 'NUR 401 - Community Health Nursing - II';
    ELSE
      v_course_name := '';
    END IF;

    UPDATE auth.users
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || 
      jsonb_build_object(
        'student_id', NEW.student_id,
        'academic_year', NEW.academic_year,
        'semester', NEW.semester,
        'course_name', v_course_name,
        'full_name', NEW.full_name,
        'phone', NEW.phone,
        'dob', to_char(NEW.dob, 'DDMMYYYY')
      )
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_sync_profile_to_auth_users ON public.profiles;
CREATE TRIGGER trigger_sync_profile_to_auth_users
AFTER UPDATE OF semester, academic_year, full_name, phone, dob ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sync_profile_to_auth_users();

-- 5. Create enroll_student PostgreSQL function (runs with SECURITY DEFINER privileges)
CREATE OR REPLACE FUNCTION public.enroll_student(
  p_email TEXT,
  p_password TEXT,
  p_student_id TEXT,
  p_full_name TEXT,
  p_phone TEXT,
  p_dob DATE,
  p_semester TEXT,
  p_academic_year TEXT
) RETURNS UUID SECURITY DEFINER AS $$
DECLARE
  v_user_id UUID;
  v_course_name TEXT;
  v_encrypted_password TEXT;
BEGIN
  -- Determine course name
  IF p_semester = '5th Sem' THEN
    v_course_name := 'NUR 303 - Community Health Nursing - I';
  ELSIF p_semester = '7th Sem' THEN
    v_course_name := 'NUR 401 - Community Health Nursing - II';
  ELSE
    v_course_name := '';
  END IF;

  v_encrypted_password := crypt(p_password, gen_salt('bf'));

  -- Check if user already exists in auth
  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email;

  IF v_user_id IS NOT NULL THEN
    -- Update existing user auth password & metadata (also repair NULL token columns for login)
    UPDATE auth.users
    SET 
      encrypted_password = v_encrypted_password,
      email_confirmed_at = COALESCE(email_confirmed_at, now()),
      confirmation_token = COALESCE(confirmation_token, ''),
      recovery_token = COALESCE(recovery_token, ''),
      email_change = COALESCE(email_change, ''),
      email_change_token_new = COALESCE(email_change_token_new, ''),
      email_change_token_current = COALESCE(email_change_token_current, ''),
      raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object(
        'student_id', p_student_id,
        'academic_year', p_academic_year,
        'semester', p_semester,
        'course_name', v_course_name,
        'full_name', p_full_name,
        'phone', p_phone,
        'dob', to_char(p_dob, 'DDMMYYYY')
      ),
      phone = p_phone,
      updated_at = now()
    WHERE id = v_user_id;

    -- Update profile
    INSERT INTO public.profiles (id, full_name, role, student_id, semester, academic_year, dob, phone)
    VALUES (v_user_id, p_full_name, 'student', p_student_id, p_semester, p_academic_year, p_dob, p_phone)
    ON CONFLICT (id) DO UPDATE
    SET 
      full_name = EXCLUDED.full_name,
      student_id = EXCLUDED.student_id,
      semester = EXCLUDED.semester,
      academic_year = EXCLUDED.academic_year,
      dob = EXCLUDED.dob,
      phone = EXCLUDED.phone;
  ELSE
    -- Create new user
    v_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      confirmation_token,
      recovery_token,
      email_change,
      email_change_token_new,
      email_change_token_current,
      raw_app_meta_data,
      raw_user_meta_data,
      aud,
      role,
      phone,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      '00000000-0000-0000-0000-000000000000',
      p_email,
      v_encrypted_password,
      now(),
      '',
      '',
      '',
      '',
      '',
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      jsonb_build_object(
        'sub', v_user_id::text,
        'email', p_email,
        'email_verified', true,
        'phone_verified', false,
        'student_id', p_student_id,
        'academic_year', p_academic_year,
        'semester', p_semester,
        'course_name', v_course_name,
        'full_name', p_full_name,
        'phone', p_phone,
        'dob', to_char(p_dob, 'DDMMYYYY')
      ),
      'authenticated',
      'authenticated',
      p_phone,
      now(),
      now()
    );

    -- Insert identity linked to user
    INSERT INTO auth.identities (
      id,
      user_id,
      identity_data,
      provider,
      provider_id,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', p_email, 'email_verified', true),
      'email',
      v_user_id::text,
      now(),
      now(),
      now()
    );

    -- Insert profile
    INSERT INTO public.profiles (id, full_name, role, student_id, semester, academic_year, dob, phone)
    VALUES (v_user_id, p_full_name, 'student', p_student_id, p_semester, p_academic_year, p_dob, p_phone);
  END IF;

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- 5b. Repair existing bulk-enrolled students (fixes "Database error querying schema" on login)
UPDATE auth.users
SET
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  email_change = COALESCE(email_change, ''),
  email_change_token_new = COALESCE(email_change_token_new, ''),
  email_change_token_current = COALESCE(email_change_token_current, '')
WHERE email LIKE '%@charusat.edu.in'
  AND (
    confirmation_token IS NULL
    OR recovery_token IS NULL
    OR email_change IS NULL
    OR email_change_token_new IS NULL
    OR email_change_token_current IS NULL
  );

-- auth.identities.email is GENERATED from identity_data; no manual UPDATE needed.

-- 6. Add policy to allow updates on profiles (required since Admin panel runs with anonymous client/local auth)
DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can update profiles" ON public.profiles;
CREATE POLICY "Anyone can update profiles"
  ON public.profiles FOR UPDATE
  USING (true);
