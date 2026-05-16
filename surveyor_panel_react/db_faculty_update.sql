-- 1. Create a Profiles table to store user roles and names
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('student', 'faculty', 'admin', 'surveyor')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Enable RLS for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow everyone to view profiles (so students can see faculty list)
CREATE POLICY "Anyone can view profiles"
  ON profiles FOR SELECT
  USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 2. Update requirement_submissions for evaluation
ALTER TABLE requirement_submissions ADD COLUMN IF NOT EXISTS assigned_faculty_id UUID REFERENCES profiles(id);
ALTER TABLE requirement_submissions ADD COLUMN IF NOT EXISTS marks_obtained NUMERIC;
ALTER TABLE requirement_submissions ADD COLUMN IF NOT EXISTS max_marks NUMERIC;
ALTER TABLE requirement_submissions ADD COLUMN IF NOT EXISTS faculty_remarks TEXT;
ALTER TABLE requirement_submissions ADD COLUMN IF NOT EXISTS evaluation_data JSONB;

-- 3. In the future, statuses could be: 'draft', 'submitted', 'resubmission_required', 'approved'
-- We don't need to alter the default status type if it's currently TEXT.
