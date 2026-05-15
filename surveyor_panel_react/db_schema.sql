-- Create the table for Survey Assignments
create table survey_assignments (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  surveyor_id uuid references auth.users not null,
  student_id text not null,
  area_name text not null,
  house_no int not null,
  remarks text,
  reason text
);

-- Enable Row Level Security (RLS)
alter table survey_assignments enable row level security;

-- Policy: Surveyors can insert their own assignments
create policy "Surveyors can create assignments"
  on survey_assignments for insert
  with check (auth.uid() = surveyor_id);

-- Policy: Surveyors can view their own assignments
create policy "Surveyors can view their own assignments"
  on survey_assignments for select
  using (auth.uid() = surveyor_id);

-- Create the table for Requirement Submissions
create table requirement_submissions (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  student_id text not null,
  course_name text not null,
  requirement_sr_no text not null,
  form_data jsonb not null,
  status text default 'draft'
);

-- Enable RLS
alter table requirement_submissions enable row level security;

-- Policy: Anyone can insert
create policy "Anyone can create submissions"
  on requirement_submissions for insert
  with check (true);

-- Policy: Anyone can view submissions
create policy "Anyone can view submissions"
  on requirement_submissions for select
  using (true);
  
-- Policy: Anyone can update submissions
create policy "Anyone can update submissions"
  on requirement_submissions for update
  using (true);
