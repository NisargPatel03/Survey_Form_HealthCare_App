-- Run this if you already created the table with ranges
-- This will DROP the old table and create the new one to ensure clean state
DROP TABLE IF EXISTS survey_assignments;

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

-- Policies
create policy "Surveyors can create assignments"
  on survey_assignments for insert
  with check (auth.uid() = surveyor_id);

create policy "Surveyors can view their own assignments"
  on survey_assignments for select
  using (auth.uid() = surveyor_id);
