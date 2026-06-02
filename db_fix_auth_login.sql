-- Run this in Supabase SQL Editor to fix student login ("Database error querying schema").
-- Safe to run multiple times.

-- 1. Repair existing bulk-enrolled auth.users (NULL token columns break GoTrue login)
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

-- Note: auth.identities.email is a GENERATED column — do not INSERT/UPDATE it.
-- Ensure identity_data contains "email"; the column is computed automatically.

-- 2. Replace enroll_student with token-safe inserts/updates
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
  IF p_semester = '5th Sem' THEN
    v_course_name := 'NUR 303 - Community Health Nursing - I';
  ELSIF p_semester = '7th Sem' THEN
    v_course_name := 'NUR 401 - Community Health Nursing - II';
  ELSE
    v_course_name := '';
  END IF;

  v_encrypted_password := crypt(p_password, gen_salt('bf'));

  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email;

  IF v_user_id IS NOT NULL THEN
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

    INSERT INTO public.profiles (id, full_name, role, student_id, semester, academic_year, dob, phone)
    VALUES (v_user_id, p_full_name, 'student', p_student_id, p_semester, p_academic_year, p_dob, p_phone);
  END IF;

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;
